//
//  EvaluationAPIService.swift
//  transport-disruption-app
//
//  Uploads participant evaluation responses to Supabase.
//

import Foundation

final class EvaluationAPIService {

    static let shared = EvaluationAPIService()

    private init() {}


    // MARK: - Supabase Payload

    private struct EvaluationPayload: Encodable {

        let origin: String
        let destination: String
        let selected_route: String
        let selected_modes: String
        let expected_arrival: String

        let disruption_impact_clarity: Int
        let option_comparison_ease: Int
        let next_step_clarity: Int
        let information_decision_confidence: Int
        let final_decision_confidence: Int

        let confusing_or_missing: String
        let improvement_suggestion: String
        let remaining_uncertainty: String

        let useful_early_service: Bool
        let useful_delayed_service: Bool
        let useful_cancelled_changed_service: Bool
        let useful_on_time_service: Bool

        let useful_other: String
    }


    // MARK: - Upload Evaluation

    func uploadEvaluation(
        journey: Journey,
        disruptionImpactClarity: Int,
        optionComparisonEase: Int,
        nextStepClarity: Int,
        informationDecisionConfidence: Int,
        finalDecisionConfidence: Int,
        confusingOrMissing: String,
        improvementSuggestion: String,
        remainingUncertainty: String,
        usefulSituations: Set<String>,
        otherSituation: String
    ) async throws {

        guard
            SupabaseConfig.publishableKey !=
                "PASTE_YOUR_SUPABASE_PUBLISHABLE_KEY_HERE",
            !SupabaseConfig.publishableKey.isEmpty
        else {
            throw EvaluationAPIError.missingPublishableKey
        }

        let selectedOption = journey.selectedOption

        let payload = EvaluationPayload(
            origin: journey.origin,
            destination: journey.destination,
            selected_route:
                selectedOption?.routeSummary ?? "",
            selected_modes:
                selectedOption?.transportModeText ?? "",
            expected_arrival:
                selectedOption?.expectedArrival ?? "",

            disruption_impact_clarity:
                disruptionImpactClarity,
            option_comparison_ease:
                optionComparisonEase,
            next_step_clarity:
                nextStepClarity,
            information_decision_confidence:
                informationDecisionConfidence,
            final_decision_confidence:
                finalDecisionConfidence,

            confusing_or_missing:
                confusingOrMissing.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
            improvement_suggestion:
                improvementSuggestion.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
            remaining_uncertainty:
                remainingUncertainty.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),

            useful_early_service:
                usefulSituations.contains(
                    "Early service"
                ),
            useful_delayed_service:
                usefulSituations.contains(
                    "Delayed service"
                ),
            useful_cancelled_changed_service:
                usefulSituations.contains(
                    "Cancelled or changed service"
                ),
            useful_on_time_service:
                usefulSituations.contains(
                    "On-time service"
                ),

            useful_other:
                otherSituation.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
        )

        let endpoint =
            SupabaseConfig.projectURL
                .appendingPathComponent(
                    "rest/v1/evaluation_responses"
                )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"

        // Supabase publishable keys are sent using the apikey header.
        request.setValue(
            SupabaseConfig.publishableKey,
            forHTTPHeaderField: "apikey"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        // Do not request the inserted row back.
        // This avoids needing a SELECT policy.
        request.setValue(
            "return=minimal",
            forHTTPHeaderField: "Prefer"
        )

        request.httpBody =
            try JSONEncoder().encode(payload)

        let (data, response) =
            try await URLSession.shared.data(
                for: request
            )

        guard
            let httpResponse =
                response as? HTTPURLResponse
        else {
            throw EvaluationAPIError.invalidResponse
        }

        guard
            (200...299)
                .contains(httpResponse.statusCode)
        else {
            let serverMessage =
                String(
                    data: data,
                    encoding: .utf8
                ) ?? "Unknown server error"

            throw EvaluationAPIError.serverError(
                statusCode:
                    httpResponse.statusCode,
                message:
                    serverMessage
            )
        }

        print(
            "✅ Evaluation uploaded to Supabase"
        )
    }
}


// MARK: - API Errors

enum EvaluationAPIError:
    LocalizedError {

    case missingPublishableKey
    case invalidResponse
    case serverError(
        statusCode: Int,
        message: String
    )

    var errorDescription: String? {
        switch self {

        case .missingPublishableKey:
            return """
            Supabase publishable key has not been added.
            """

        case .invalidResponse:
            return """
            Supabase returned an invalid response.
            """

        case let .serverError(
            statusCode,
            message
        ):
            return """
            Supabase upload failed (\(statusCode)):
            \(message)
            """
        }
    }
}
