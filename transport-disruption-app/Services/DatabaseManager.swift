//
//  DatabaseManager.swift
//  transport-disruption-app
//

import Foundation
import SQLite3


final class DatabaseManager {

    static let shared = DatabaseManager()

    private var db: OpaquePointer?


    // ========================================================
    // MARK: - Initialisation
    // ========================================================

    private init() {

        openDatabase()
    }


    deinit {

        if db != nil {

            sqlite3_close(
                db
            )
        }
    }


    // ========================================================
    // MARK: - Open Database
    // ========================================================

    private func openDatabase() {

        guard let databaseURL =
                Bundle.main.url(
                    forResource:
                        "transport_simulation",

                    withExtension:
                        "db"
                )
        else {

            print(
                "❌ transport_simulation.db not found in app bundle"
            )

            return
        }


        let result =
            sqlite3_open_v2(

                databaseURL.path,

                &db,

                SQLITE_OPEN_READONLY,

                nil
            )


        if result == SQLITE_OK {

            print(
                "✅ SQLite database opened successfully"
            )

            print(
                "📁 \(databaseURL.path)"
            )

        } else {

            print(
                "❌ Failed to open SQLite database"
            )

            db = nil
        }
    }


    // ========================================================
    // MARK: - PAGE 1
    // ========================================================


    // ========================================================
    // MARK: Available Origins
    // ========================================================

    func availableOrigins() -> [String] {

        /*
         Page 1 now searches complete journeys rather than
         individual services.

         Internal interchange locations are hidden because they
         are normally used inside a JourneyOption rather than as
         passenger-facing starting points.
         */

        let sql = """
        SELECT DISTINCT origin

        FROM journey_options

        WHERE origin NOT IN (
            'UQ Ferry Terminal',
            'South Bank Ferry Terminal',
            'North Quay'
        )

        ORDER BY origin
        """


        var statement:
            OpaquePointer?


        var origins:
            [String] = []


        guard sqlite3_prepare_v2(
            db,
            sql,
            -1,
            &statement,
            nil
        ) == SQLITE_OK
        else {

            printDatabaseError(
                message:
                    "Failed to load journey origins"
            )

            return []
        }


        while sqlite3_step(statement)
            == SQLITE_ROW {

            let origin =
                textValue(
                    statement,
                    index: 0
                )


            if !origin.isEmpty {

                origins.append(
                    origin
                )
            }
        }


        sqlite3_finalize(
            statement
        )


        return origins
    }


    // ========================================================
    // MARK: Available Destinations
    // ========================================================

    func availableDestinations(
        from origin: String
    ) -> [String] {

        /*
         IMPORTANT:

         Destinations are now taken from journey_options.

         This means Page 1 can offer destinations reachable by
         either:

         - Direct journeys
         - Transfer journeys
         - Ferry / walking combinations
         */

        let sql = """
        SELECT DISTINCT destination

        FROM journey_options

        WHERE origin = ?

        ORDER BY destination
        """


        var statement:
            OpaquePointer?


        var destinations:
            [String] = []


        guard sqlite3_prepare_v2(
            db,
            sql,
            -1,
            &statement,
            nil
        ) == SQLITE_OK
        else {

            printDatabaseError(
                message:
                    "Failed to load journey destinations"
            )

            return []
        }


        bindText(
            origin,
            to: statement,
            index: 1
        )


        while sqlite3_step(statement)
            == SQLITE_ROW {

            let destination =
                textValue(
                    statement,
                    index: 0
                )


            if !destination.isEmpty {

                destinations.append(
                    destination
                )
            }
        }


        sqlite3_finalize(
            statement
        )


        return destinations
    }


    // ========================================================
    // MARK: Search Current Journeys
    // ========================================================

    func searchCurrentJourneys(
        origin: String,
        destination: String,
        selectedTime: Date
    ) -> [JourneyOption] {

        /*
         PAGE 1 RULES

         1. Search complete JourneyOptions.
         2. Include direct AND transfer journeys.
         3. First scheduled departure must be within ±10 minutes.
         4. Similar repeated route patterns are grouped.
         5. Keep the journey closest to the selected time
            for each route pattern.
         6. Display at most 10 journeys.

         IMPORTANT:

         Cancelled journeys are NOT removed here.

         Page 1 represents the journey the passenger originally
         intended to take. A passenger must therefore still be
         able to select a journey that has subsequently been
         cancelled and view that disruption on Page 2.
         */


        let allOptions =
            loadJourneyOptions(
                origin:
                    origin,

                destination:
                    destination
            )


        let selectedMinutes =
            minutesFromDate(
                selectedTime
            )


        // ----------------------------------------------------
        // 1. ±10 minute filter
        // ----------------------------------------------------

        let nearbyOptions =
            allOptions.filter {

                option in


                guard let departure =
                        scheduledDeparture(
                            for:
                                option
                        )
                else {

                    return false
                }


                let departureMinutes =
                    minutesFromTimeString(
                        departure
                    )


                guard departureMinutes >= 0
                else {

                    return false
                }


                let difference =
                    absoluteMinuteDifference(

                        selectedMinutes,

                        departureMinutes
                    )


                return difference <= 10
            }


        // ----------------------------------------------------
        // 2. Remove repeated journey patterns
        // ----------------------------------------------------

        var bestJourneyForPattern:
            [String: JourneyOption] = [:]


        for option in nearbyOptions {

            let key =
                journeyPatternKey(
                    for:
                        option
                )


            guard let existing =
                    bestJourneyForPattern[key]
            else {

                bestJourneyForPattern[key] =
                    option

                continue
            }


            let newDifference =
                departureDifference(

                    option:
                        option,

                    selectedMinutes:
                        selectedMinutes
                )


            let existingDifference =
                departureDifference(

                    option:
                        existing,

                    selectedMinutes:
                        selectedMinutes
                )


            // Prefer the departure closest to user-selected time.

            if newDifference <
                existingDifference {

                bestJourneyForPattern[key] =
                    option

            } else if newDifference ==
                        existingDifference {

                /*
                 Tie breaker:
                 prefer earlier expected arrival.
                 */

                let newArrival =
                    minutesFromTimeString(
                        option.expectedArrival
                    )


                let existingArrival =
                    minutesFromTimeString(
                        existing.expectedArrival
                    )


                if newArrival <
                    existingArrival {

                    bestJourneyForPattern[key] =
                        option
                }
            }
        }


        // ----------------------------------------------------
        // 3. Sort by closeness to selected time
        // ----------------------------------------------------

        let sortedOptions =
            Array(
                bestJourneyForPattern.values
            )
            .sorted {

                first,
                second in


                let firstDifference =
                    departureDifference(

                        option:
                            first,

                        selectedMinutes:
                            selectedMinutes
                    )


                let secondDifference =
                    departureDifference(

                        option:
                            second,

                        selectedMinutes:
                            selectedMinutes
                    )


                // Primary:
                // departure closest to selected time

                if firstDifference !=
                    secondDifference {

                    return firstDifference <
                        secondDifference
                }


                // Secondary:
                // earlier departure

                let firstDeparture =
                    scheduledDepartureMinutes(
                        for:
                            first
                    )


                let secondDeparture =
                    scheduledDepartureMinutes(
                        for:
                            second
                    )


                if firstDeparture !=
                    secondDeparture {

                    return firstDeparture <
                        secondDeparture
                }


                // Third:
                // earlier expected arrival

                let firstArrival =
                    minutesFromTimeString(
                        first.expectedArrival
                    )


                let secondArrival =
                    minutesFromTimeString(
                        second.expectedArrival
                    )


                return firstArrival <
                    secondArrival
            }


        // ----------------------------------------------------
        // 4. Maximum 10
        // ----------------------------------------------------

        return Array(
            sortedOptions.prefix(10)
        )
    }


    // ========================================================
    // MARK: - PAGE 3
    // ========================================================


    // ========================================================
    // MARK: Find Decision Options
    // ========================================================

    func findDecisionOptions(
        currentJourney: JourneyOption,
        selectedTime: Date
    ) -> [JourneyOption] {

        /*
         PAGE 3 RULES

         Decision Support compares:

         1. Current journey itself, if not cancelled
         2. Other direct journeys
         3. Transfer journeys
         4. Ferry / walking journeys

         Alternative journeys must begin from the selected
         time up to +20 minutes.

         Current Journey is always preserved even when its
         departure lies slightly before the selected time,
         because Page 1 allowed ±10 minutes.

         Ranking:

         1. Earlier expected arrival
         2. Fewer transfers
         3. Lower delay
         4. Shorter total journey time

         Maximum = 5.
         */


        let allOptions =
            loadJourneyOptions(

                origin:
                    currentJourney.origin,

                destination:
                    currentJourney.destination
            )


        let selectedMinutes =
            minutesFromDate(
                selectedTime
            )


        var decisionOptions:
            [JourneyOption] = []


        for option in allOptions {

            // Current journey is added separately below.

            if option.id ==
                currentJourney.id {

                continue
            }


            // Cancelled alternatives cannot be selected.

            if option.isCancelled {

                continue
            }


            let departureMinutes =
                minutesFromTimeString(
                    option.expectedDeparture
                )


            guard departureMinutes >= 0
            else {

                continue
            }


            let difference =
                forwardMinuteDifference(

                    from:
                        selectedMinutes,

                    to:
                        departureMinutes
                )


            // Other alternatives:
            // selected time → +20 minutes

            guard
                difference >= 0,
                difference <= 20
            else {

                continue
            }


            decisionOptions.append(
                option
            )
        }


        // ----------------------------------------------------
        // Add current journey
        // ----------------------------------------------------

        if !currentJourney.isCancelled {

            decisionOptions.append(
                currentJourney
            )
        }


        // ----------------------------------------------------
        // Remove exact duplicates
        // ----------------------------------------------------

        let uniqueOptions =
            removeExactDuplicateOptions(
                decisionOptions
            )


        // ----------------------------------------------------
        // Ranking
        // ----------------------------------------------------

        let rankedOptions =
            uniqueOptions.sorted {

                first,
                second in


                let firstArrival =
                    minutesFromTimeString(
                        first.expectedArrival
                    )


                let secondArrival =
                    minutesFromTimeString(
                        second.expectedArrival
                    )


                // 1. Expected Arrival

                if firstArrival !=
                    secondArrival {

                    return firstArrival <
                        secondArrival
                }


                // 2. Transfers

                if first.transfers !=
                    second.transfers {

                    return first.transfers <
                        second.transfers
                }


                // 3. Delay

                if first.totalDelayMinutes !=
                    second.totalDelayMinutes {

                    return first.totalDelayMinutes <
                        second.totalDelayMinutes
                }


                // 4. Duration

                return first.totalMinutes <
                    second.totalMinutes
            }


        return Array(
            rankedOptions.prefix(5)
        )
    }


    // ========================================================
    // MARK: - Compatibility Name
    // ========================================================

    func findAlternativeOptions(
        currentJourney: JourneyOption,
        selectedTime: Date
    ) -> [JourneyOption] {

        /*
         Kept because the existing project previously used
         the name "findAlternativeOptions".

         The important change is that the input is now a
         JourneyOption instead of a TransportService ID.
         */

        return findDecisionOptions(

            currentJourney:
                currentJourney,

            selectedTime:
                selectedTime
        )
    }


    // ========================================================
    // MARK: - Load Journey Options
    // ========================================================

    private func loadJourneyOptions(
        origin: String,
        destination: String
    ) -> [JourneyOption] {

        let sql = """
        SELECT

            id,
            origin,
            destination,

            expected_departure,
            expected_arrival,

            total_minutes,
            transfers

        FROM journey_options

        WHERE origin = ?
          AND destination = ?

        ORDER BY expected_departure
        """


        var statement:
            OpaquePointer?


        var options:
            [JourneyOption] = []


        guard sqlite3_prepare_v2(
            db,
            sql,
            -1,
            &statement,
            nil
        ) == SQLITE_OK
        else {

            printDatabaseError(
                message:
                    "Failed to load journey options"
            )

            return []
        }


        bindText(
            origin,
            to: statement,
            index: 1
        )


        bindText(
            destination,
            to: statement,
            index: 2
        )


        while sqlite3_step(statement)
            == SQLITE_ROW {

            let optionID =
                Int(
                    sqlite3_column_int(
                        statement,
                        0
                    )
                )


            let optionOrigin =
                textValue(
                    statement,
                    index: 1
                )


            let optionDestination =
                textValue(
                    statement,
                    index: 2
                )


            let expectedDeparture =
                textValue(
                    statement,
                    index: 3
                )


            let expectedArrival =
                textValue(
                    statement,
                    index: 4
                )


            let totalMinutes =
                Int(
                    sqlite3_column_int(
                        statement,
                        5
                    )
                )


            let transfers =
                Int(
                    sqlite3_column_int(
                        statement,
                        6
                    )
                )


            let segments =
                loadJourneySegments(
                    optionID:
                        optionID
                )


            guard !segments.isEmpty
            else {

                continue
            }


            let option =
                JourneyOption(

                    id:
                        optionID,

                    origin:
                        optionOrigin,

                    destination:
                        optionDestination,

                    segments:
                        segments,

                    totalMinutes:
                        totalMinutes,

                    transfers:
                        transfers,

                    expectedDeparture:
                        expectedDeparture,

                    expectedArrival:
                        expectedArrival
                )


            options.append(
                option
            )
        }


        sqlite3_finalize(
            statement
        )


        return options
    }


    // ========================================================
    // MARK: - Load Journey Segments
    // ========================================================

    private func loadJourneySegments(
        optionID: Int
    ) -> [JourneySegment] {

        /*
         The current database stores each complete JourneyOption
         as one or more JourneySegments.
         */

        let sql = """
        SELECT

            id,
            sequence,

            transport_mode,

            route_id,
            route_name,

            origin,
            destination,

            scheduled_departure,
            scheduled_arrival,

            expected_departure,
            expected_arrival,

            duration_minutes,

            disruption_type,
            delay_minutes

        FROM journey_segments

        WHERE option_id = ?

        ORDER BY sequence
        """


        var statement:
            OpaquePointer?


        var segments:
            [JourneySegment] = []


        guard sqlite3_prepare_v2(
            db,
            sql,
            -1,
            &statement,
            nil
        ) == SQLITE_OK
        else {

            printDatabaseError(
                message:
                    "Failed to load journey segments"
            )

            return []
        }


        sqlite3_bind_int(
            statement,
            1,
            Int32(optionID)
        )


        while sqlite3_step(statement)
            == SQLITE_ROW {

            let segment =
                JourneySegment(

                    id:
                        Int(
                            sqlite3_column_int(
                                statement,
                                0
                            )
                        ),

                    sequence:
                        Int(
                            sqlite3_column_int(
                                statement,
                                1
                            )
                        ),

                    transportMode:
                        textValue(
                            statement,
                            index: 2
                        ),

                    routeID:
                        optionalTextValue(
                            statement,
                            index: 3
                        ),

                    routeName:
                        textValue(
                            statement,
                            index: 4
                        ),

                    origin:
                        textValue(
                            statement,
                            index: 5
                        ),

                    destination:
                        textValue(
                            statement,
                            index: 6
                        ),

                    scheduledDeparture:
                        optionalTextValue(
                            statement,
                            index: 7
                        ),

                    scheduledArrival:
                        optionalTextValue(
                            statement,
                            index: 8
                        ),

                    expectedDeparture:
                        optionalTextValue(
                            statement,
                            index: 9
                        ),

                    expectedArrival:
                        optionalTextValue(
                            statement,
                            index: 10
                        ),

                    durationMinutes:
                        Int(
                            sqlite3_column_int(
                                statement,
                                11
                            )
                        ),

                    disruptionType:
                        textValue(
                            statement,
                            index: 12
                        ),

                    delayMinutes:
                        Int(
                            sqlite3_column_int(
                                statement,
                                13
                            )
                        )
                )


            segments.append(
                segment
            )
        }


        sqlite3_finalize(
            statement
        )


        return segments
    }


    // ========================================================
    // MARK: - Page 1 Journey Pattern
    // ========================================================

    private func journeyPatternKey(
        for option: JourneyOption
    ) -> String {

        /*
         Two journeys are considered the same repeating pattern
         when they use the same ordered transport / route
         combination.

         Examples:

         Route 66 08:10
         Route 66 08:15
         Route 66 08:20
         → same pattern


         Route 412 → Ipswich Line 08:12
         Route 412 → Ipswich Line 08:22
         → same pattern


         Route 412 → Ipswich Line
         Route 412 → Route 444
         → different patterns
         */


        return option
            .orderedSegments
            .map {

                segment in


                let route =
                    segment.routeID
                    ??
                    segment.routeName


                return [
                    segment.transportMode
                        .lowercased(),

                    route
                        .lowercased(),

                    segment.origin
                        .lowercased(),

                    segment.destination
                        .lowercased()
                ]
                .joined(
                    separator:
                        "|"
                )
            }
            .joined(
                separator:
                    ">>"
            )
    }


    // ========================================================
    // MARK: - Remove Exact Decision Duplicates
    // ========================================================

    private func removeExactDuplicateOptions(
        _ options: [JourneyOption]
    ) -> [JourneyOption] {

        /*
         Page 3 does NOT remove later services merely because
         they use the same route pattern.

         It only prevents the exact same journey from appearing
         twice.
         */

        var seen:
            Set<String> = []


        var results:
            [JourneyOption] = []


        for option in options {

            let key =
                exactJourneyKey(
                    for:
                        option
                )


            if seen.contains(
                key
            ) {

                continue
            }


            seen.insert(
                key
            )


            results.append(
                option
            )
        }


        return results
    }


    private func exactJourneyKey(
        for option: JourneyOption
    ) -> String {

        let segmentKey =
            option
                .orderedSegments
                .map {

                    segment in


                    [
                        segment.transportMode,
                        segment.routeID
                            ?? segment.routeName,
                        segment.origin,
                        segment.destination,
                        segment.scheduledDeparture
                            ?? "",
                        segment.scheduledArrival
                            ?? ""
                    ]
                    .joined(
                        separator:
                            "|"
                    )
                }
                .joined(
                    separator:
                        ">>"
                )


        return """
        \(option.origin)|\(option.destination)|\(segmentKey)
        """
    }


    // ========================================================
    // MARK: - Scheduled Departure
    // ========================================================

    private func scheduledDeparture(
        for option: JourneyOption
    ) -> String? {

        /*
         Page 1 is asking:
         "Which journey were you planning to take?"

         Therefore Page 1 uses the scheduled departure of the
         FIRST segment when it is available, rather than the
         disruption-adjusted expected departure.

         Walking segments are still valid first segments for
         ferry-based complete journeys.
         */


        guard let firstSegment =
                option.orderedSegments.first
        else {

            return nil
        }


        return firstSegment.scheduledDeparture
            ??
            firstSegment.expectedDeparture
            ??
            option.expectedDeparture
    }


    private func scheduledDepartureMinutes(
        for option: JourneyOption
    ) -> Int {

        guard let departure =
                scheduledDeparture(
                    for:
                        option
                )
        else {

            return Int.max
        }


        let value =
            minutesFromTimeString(
                departure
            )


        if value < 0 {

            return Int.max
        }


        return value
    }


    private func departureDifference(
        option: JourneyOption,
        selectedMinutes: Int
    ) -> Int {

        let departure =
            scheduledDepartureMinutes(
                for:
                    option
            )


        guard departure !=
                Int.max
        else {

            return Int.max
        }


        return absoluteMinuteDifference(

            selectedMinutes,

            departure
        )
    }


    // ========================================================
    // MARK: - SQLite Helpers
    // ========================================================

    private func bindText(
        _ value: String,
        to statement: OpaquePointer?,
        index: Int32
    ) {

        sqlite3_bind_text(
            statement,
            index,
            value,
            -1,
            SQLITE_TRANSIENT
        )
    }


    private func textValue(
        _ statement: OpaquePointer?,
        index: Int32
    ) -> String {

        guard let text =
                sqlite3_column_text(
                    statement,
                    index
                )
        else {

            return ""
        }


        return String(
            cString:
                text
        )
    }


    private func optionalTextValue(
        _ statement: OpaquePointer?,
        index: Int32
    ) -> String? {

        if sqlite3_column_type(
            statement,
            index
        ) == SQLITE_NULL {

            return nil
        }


        guard let text =
                sqlite3_column_text(
                    statement,
                    index
                )
        else {

            return nil
        }


        return String(
            cString:
                text
        )
    }


    // ========================================================
    // MARK: - Time Helpers
    // ========================================================

    private func minutesFromDate(
        _ date: Date
    ) -> Int {

        let components =
            Calendar.current.dateComponents(
                [
                    .hour,
                    .minute
                ],
                from:
                    date
            )


        let hour =
            components.hour
            ?? 0


        let minute =
            components.minute
            ?? 0


        return hour * 60
            + minute
    }


    private func minutesFromTimeString(
        _ time: String
    ) -> Int {

        let components =
            time.split(
                separator:
                    ":"
            )


        guard
            components.count >= 2,

            let hour =
                Int(
                    components[0]
                ),

            let minute =
                Int(
                    components[1]
                )

        else {

            return -1
        }


        return hour * 60
            + minute
    }


    // ========================================================
    // MARK: - Page 1 Absolute Time Difference
    // ========================================================

    private func absoluteMinuteDifference(
        _ first: Int,
        _ second: Int
    ) -> Int {

        let normalDifference =
            abs(
                first -
                second
            )


        let midnightDifference =
            1440 -
            normalDifference


        return min(
            normalDifference,
            midnightDifference
        )
    }


    // ========================================================
    // MARK: - Page 3 Forward Time Difference
    // ========================================================

    private func forwardMinuteDifference(
        from start: Int,
        to end: Int
    ) -> Int {

        if end >= start {

            return end -
                start
        }


        return (
            1440 -
            start
        ) + end
    }


    // ========================================================
    // MARK: - Error
    // ========================================================

    private func printDatabaseError(
        message: String
    ) {

        guard let db
        else {

            print(
                "❌ \(message): Database is not open"
            )

            return
        }


        let errorMessage =
            String(
                cString:
                    sqlite3_errmsg(
                        db
                    )
            )


        print(
            "❌ \(message): \(errorMessage)"
        )
    }
}


// ============================================================
// MARK: - SQLite Destructor
// ============================================================

private let SQLITE_TRANSIENT =
    unsafeBitCast(
        -1,
        to:
            sqlite3_destructor_type.self
    )
