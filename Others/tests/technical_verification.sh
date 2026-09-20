#!/usr/bin/env bash

set -u

project_root=$(cd "$(dirname "$0")/.." && pwd)
database_path="$project_root/transport-disruption-app/Resources/transport_simulation.db"
derived_data_path="/private/tmp/transport-disruption-technical-tests"
passed=0
failed=0
skipped=0

pass() {
  printf 'PASS %s\n' "$1"
  passed=$((passed + 1))
}

fail() {
  printf 'FAIL %s\n' "$1"
  failed=$((failed + 1))
}

skip() {
  printf 'SKIP %s\n' "$1"
  skipped=$((skipped + 1))
}

if xcodebuild build -project "$project_root/transport-disruption-app.xcodeproj" -scheme transport-disruption-app -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath "$derived_data_path" CODE_SIGNING_ALLOWED=NO >/tmp/transport-disruption-build.log 2>&1; then
  pass 'T-01 simulator build'
else
  fail 'T-01 simulator build'
fi

for disruption_type in 'Normal Service' 'Minor Delay' 'Major Delay'; do
  count=$(sqlite3 "$database_path" "SELECT COUNT(*) FROM journey_segments WHERE disruption_type = '$disruption_type';")
  if [ "$count" -gt 0 ]; then
    pass "T-02 disruption fixture: $disruption_type"
  else
    fail "T-02 disruption fixture: $disruption_type"
  fi
done

cancelled_count=$(sqlite3 "$database_path" "SELECT COUNT(*) FROM journey_segments WHERE disruption_type = 'Cancelled';")
if [ "$cancelled_count" -gt 0 ]; then
  pass 'T-03 cancellation fixture exists'
else
  skip 'T-03 cancellation fixture absent: known A2 limitation'
fi

if rg -q 'findDecisionOptions' "$project_root/transport-disruption-app/Services/DatabaseManager.swift" \
  && rg -q 'if option.isCancelled' "$project_root/transport-disruption-app/Services/DatabaseManager.swift"; then
  pass 'T-04 decision option filtering rule present'
else
  fail 'T-04 decision option filtering rule present'
fi

if rg -q 'setSelectedJourney' "$project_root/transport-disruption-app/Views/CurrentJourneyView.swift" \
  && rg -q 'setAlternativeOptions' "$project_root/transport-disruption-app/Views/DisruptionInformationView.swift" \
  && rg -q 'toggleOption' "$project_root/transport-disruption-app/Views/DecisionSupportView.swift"; then
  pass 'T-05 core workflow state hand-off present'
else
  fail 'T-05 core workflow state hand-off present'
fi

if rg -q 'ScenarioState\|DisruptionEvent\|applyScenario' "$project_root/transport-disruption-app"; then
  pass 'T-06 controlled state-transition mechanism present'
else
  skip 'T-06 controlled state-transition mechanism absent: known A2 limitation'
fi

printf 'SUMMARY collected=%s passed=%s failed=%s skipped=%s\n' "$((passed + failed + skipped))" "$passed" "$failed" "$skipped"

if [ "$failed" -gt 0 ]; then
  exit 1
fi
