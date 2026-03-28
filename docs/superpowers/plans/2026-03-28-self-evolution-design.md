# Skill 自我进化与使用即进化 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add self-evolution capability (scheduled + threshold-triggered) and learn-from-usage capability to the skill system

**Architecture:** Three new components (usage_tracker, evolve_decider, learner) integrated with existing engine.sh 9-step loop. Usage data collected in logs/evolution/, decisions made by decider, learning extracted by learner.

**Tech Stack:** Bash scripts, JSON for usage data, existing LLM provider infrastructure

---

## File Structure

```
engine/
├── evolution/
│   ├── engine.sh          # Modify: enhance 9-step loop
│   ├── usage_tracker.sh   # Create: usage data collection
│   ├── evolve_decider.sh  # Create: evolution decision engine
│   └── learner.sh         # Create: pattern learning
├── lib/
│   └── bootstrap.sh       # Modify: add EVOLUTION_USAGE_DIR
SKILL.md                   # Modify: add §6 self-evolution
```

---

## Task 1: Add EVOLUTION_USAGE_DIR to bootstrap.sh

**Files:**
- Modify: `engine/lib/bootstrap.sh:25-28`

- [ ] **Step 1: Add EVOLUTION_USAGE_DIR constant**

After line 26 (after `LOCK_DIR`), add:

```bash
EVOLUTION_USAGE_DIR="${LOG_DIR}/evolution"
ensure_directory "$EVOLUTION_USAGE_DIR"
```

- [ ] **Step 2: Export the new constant**

Add to line 108 (export section):
```bash
export EVOLUTION_USAGE_DIR
```

- [ ] **Step 3: Verify bootstrap loads correctly**

Run: `cd /Users/lucas/Documents/Projects/skill && source engine/lib/bootstrap.sh && echo $EVOLUTION_USAGE_DIR`
Expected: `/Users/lucas/Documents/Projects/skill/logs/evolution`

---

## Task 2: Create usage_tracker.sh

**Files:**
- Create: `engine/evolution/usage_tracker.sh`

- [ ] **Step 1: Create usage_tracker.sh with track_usage function**

```bash
#!/usr/bin/env bash
# usage_tracker.sh - Track skill usage data for learn-from-usage

source "$(dirname "${BASH_SOURCE[0]}")/../lib/bootstrap.sh"

USAGE_TRACKER_VERSION="1.0"

init_usage_file() {
    local skill_name="$1"
    local date
    date=$(date +%Y%m%d)
    local usage_file="${EVOLUTION_USAGE_DIR}/usage_${skill_name}_${date}.jsonl"
    
    if [[ ! -f "$usage_file" ]]; then
        echo "[]" > "$usage_file"
    fi
}

track_trigger() {
    local skill_name="$1"
    local expected_mode="$2"
    local actual_mode="$3"
    
    local date
    date=$(date +%Y%m%d_%H%M%S)
    local usage_file="${EVOLUTION_USAGE_DIR}/usage_${skill_name}_$(date +%Y%m%d).jsonl"
    
    local correct="false"
    [[ "$expected_mode" == "$actual_mode" ]] && correct="true"
    
    local entry
    entry=$(jq -n \
        --arg ts "$(get_timestamp)" \
        --arg skill "$skill_name" \
        --arg type "trigger" \
        --arg expected "$expected_mode" \
        --arg actual "$actual_mode" \
        --arg correct "$correct" \
        '{timestamp: $ts, skill: $skill, event_type: $type, expected_mode: $expected, actual_mode: $actual, correct: ($correct == "true")}')
    
    echo "$entry" >> "$usage_file"
}

track_task() {
    local skill_name="$1"
    local task_type="$2"
    local completed="$3"
    local rounds="${4:-1}"
    
    local usage_file="${EVOLUTION_USAGE_DIR}/usage_${skill_name}_$(date +%Y%m%d).jsonl"
    
    local entry
    entry=$(jq -n \
        --arg ts "$(get_timestamp)" \
        --arg skill "$skill_name" \
        --arg type "task" \
        --arg task_type "$task_type" \
        --arg completed "$completed" \
        --arg rounds "$rounds" \
        '{timestamp: $ts, skill: $skill, event_type: $type, task_type: $task_type, completed: ($completed == "true"), rounds: ($rounds | tonumber)}')
    
    echo "$entry" >> "$usage_file"
}

track_feedback() {
    local skill_name="$1"
    local rating="$2"
    local comment="${3:-}"
    
    local usage_file="${EVOLUTION_USAGE_DIR}/usage_${skill_name}_$(date +%Y%m%d).jsonl"
    
    local entry
    entry=$(jq -n \
        --arg ts "$(get_timestamp)" \
        --arg skill "$skill_name" \
        --arg type "feedback" \
        --arg rating "$rating" \
        --arg comment "$comment" \
        '{timestamp: $ts, skill: $skill, event_type: $type, rating: ($rating | tonumber), comment: $comment}')
    
    echo "$entry" >> "$usage_file"
}

get_usage_summary() {
    local skill_name="$1"
    local days="${2:-7}"
    
    local total_triggers=0 correct_triggers=0
    local total_tasks=0 completed_tasks=0
    local total_feedback=0 avg_rating=0
    
    for ((i=0; i<days; i++)); do
        local date
        date=$(date -v-${i}d +%Y%m%d 2>/dev/null || date -d "-${i} days" +%Y%m%d)
        local usage_file="${EVOLUTION_USAGE_DIR}/usage_${skill_name}_${date}.jsonl"
        
        [[ ! -f "$usage_file" ]] && continue
        
        while IFS= read -r line; do
            [[ -z "$line" ]] && continue
            local event_type
            event_type=$(echo "$line" | jq -r '.event_type')
            
            case "$event_type" in
                trigger)
                    ((total_triggers++))
                    local correct
                    correct=$(echo "$line" | jq -r '.correct')
                    [[ "$correct" == "true" ]] && ((correct_triggers++))
                    ;;
                task)
                    ((total_tasks++))
                    local completed
                    completed=$(echo "$line" | jq -r '.completed')
                    [[ "$completed" == "true" ]] && ((completed_tasks++))
                    ;;
                feedback)
                    ((total_feedback++))
                    local rating
                    rating=$(echo "$line" | jq -r '.rating')
                    avg_rating=$(echo "$avg_rating + $rating" | bc)
                    ;;
            esac
        done < "$usage_file"
    done
    
    local trigger_f1=0
    [[ $total_triggers -gt 0 ]] && trigger_f1=$(echo "scale=4; $correct_triggers / $total_triggers" | bc)
    
    local task_rate=0
    [[ $total_tasks -gt 0 ]] && task_rate=$(echo "scale=4; $completed_tasks / $total_tasks" | bc)
    
    local feedback_avg=0
    [[ $total_feedback -gt 0 ]] && feedback_avg=$(echo "scale=2; $avg_rating / $total_feedback" | bc)
    
    jq -n \
        --argjson trigger_f1 "$trigger_f1" \
        --argjson task_rate "$task_rate" \
        --argjson feedback_avg "$feedback_avg" \
        --argjson total_triggers "$total_triggers" \
        --argjson correct_triggers "$correct_triggers" \
        --argjson total_tasks "$total_tasks" \
        --argjson completed_tasks "$completed_tasks" \
        --argjson total_feedback "$total_feedback" \
        '{
            trigger_f1: $trigger_f1,
            task_completion_rate: $task_rate,
            avg_feedback_rating: $feedback_avg,
            stats: {
                triggers: {total: $total_triggers, correct: $correct_triggers},
                tasks: {total: $total_tasks, completed: $completed_tasks},
                feedback: {count: $total_feedback}
            }
        }'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Usage Tracker v${USAGE_TRACKER_VERSION}"
    echo "Usage: source usage_tracker.sh and call track_* functions"
fi
```

- [ ] **Step 2: Make executable**

Run: `chmod +x engine/evolution/usage_tracker.sh`

- [ ] **Step 3: Test basic functionality**

Run: `cd /Users/lucas/Documents/Projects/skill && bash -c 'source engine/evolution/usage_tracker.sh && init_usage_file "test-skill" && track_trigger "test-skill" "OPTIMIZE" "OPTIMIZE" && track_task "test-skill" "optimization" "true" 3 && cat logs/evolution/usage_test-skill_*.jsonl'`
Expected: JSONL entries printed

---

## Task 3: Create evolve_decider.sh

**Files:**
- Create: `engine/evolution/evolve_decider.sh`

- [ ] **Step 1: Create evolve_decider.sh with decision logic**

```bash
#!/usr/bin/env bash
# evolve_decider.sh - Evolution decision engine
# Decides when to trigger self-evolution based on thresholds and schedule

source "$(dirname "${BASH_SOURCE[0]}")/../lib/bootstrap.sh"
source "${EVAL_DIR}/lib/agent_executor.sh"

EVOLVE_DECIDER_VERSION="1.0"

GOLD_THRESHOLD=475
SILVER_THRESHOLD=425
BRONZE_THRESHOLD=350

CHECK_INTERVAL_HOURS=24
LAST_CHECK_FILE="${EVOLUTION_USAGE_DIR}/.last_evolution_check"

should_evolve() {
    local skill_file="$1"
    local force="${2:-false}"
    
    local skill_name
    skill_name=$(basename "$skill_file" .md)
    
    if [[ "$force" == "true" ]]; then
        echo '{"decision": "evolve", "reason": "forced"}'
        return
    fi
    
    local current_score
    current_score=$(bash scripts/lean-orchestrator.sh "$skill_file" SILVER 2>/dev/null | jq -r '.total // 0')
    
    if (( $(echo "$current_score < $GOLD_THRESHOLD" | bc -l) )); then
        local reason="score_below_gold"
        reason="${reason}_${current_score}"
        echo "{\"decision\": \"evolve\", \"reason\": \"$reason\", \"score\": $current_score}"
        return
    fi
    
    if should_check_scheduled; then
        echo "{\"decision\": \"evolve\", \"reason\": \"scheduled\", \"score\": $current_score}"
        return
    fi
    
    local usage_summary
    usage_summary=$(source engine/evolution/usage_tracker.sh && get_usage_summary "$skill_name" 7)
    
    local trigger_f1
    trigger_f1=$(echo "$usage_summary" | jq -r '.trigger_f1')
    local task_rate
    task_rate=$(echo "$usage_summary" | jq -r '.task_completion_rate')
    
    if (( $(echo "$trigger_f1 < 0.85" | bc -l) )) || (( $(echo "$task_rate < 0.80" | bc -l) )); then
        echo "{\"decision\": \"evolve\", \"reason\": \"usage_metrics_low\", \"trigger_f1\": $trigger_f1, \"task_rate\": $task_rate, \"score\": $current_score}"
        return
    fi
    
    echo "{\"decision\": \"skip\", \"reason\": \"metrics_ok\", \"score\": $current_score, \"trigger_f1\": $trigger_f1, \"task_rate\": $task_rate}"
}

should_check_scheduled() {
    if [[ ! -f "$LAST_CHECK_FILE" ]]; then
        echo "true"
        return
    fi
    
    local last_check
    last_check=$(cat "$LAST_CHECK_FILE")
    local last_check_epoch
    last_check_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$last_check" +%s 2>/dev/null || echo "0")
    local now_epoch
    now_epoch=$(date +%s)
    local hours_elapsed=$(( (now_epoch - last_check_epoch) / 3600 ))
    
    [[ $hours_elapsed -ge $CHECK_INTERVAL_HOURS ]] && echo "true" || echo "false"
}

update_last_check() {
    echo "$(get_timestamp)" > "$LAST_CHECK_FILE"
}

get_evolution_recommendations() {
    local skill_file="$1"
    
    local skill_name
    skill_name=$(basename "$skill_file" .md)
    
    local usage_summary
    usage_summary=$(source engine/evolution/usage_tracker.sh && get_usage_summary "$skill_name" 7)
    
    local trigger_f1
    trigger_f1=$(echo "$usage_summary" | jq -r '.trigger_f1')
    local task_rate
    task_rate=$(echo "$usage_summary" | jq -r '.task_completion_rate')
    local avg_feedback
    avg_feedback=$(echo "$usage_summary" | jq -r '.avg_feedback_rating')
    
    local recommendations=()
    
    if (( $(echo "$trigger_f1 < 0.90" | bc -l) )); then
        recommendations+=("Improve trigger accuracy (current: $trigger_f1)")
    fi
    
    if (( $(echo "$task_rate < 0.85" | bc -l) )); then
        recommendations+=("Improve task completion rate (current: $task_rate)")
    fi
    
    if (( $(echo "$avg_feedback < 3.5" | bc -l) )) && (( $(echo "$avg_feedback > 0" | bc -l) )); then
        recommendations+=("Address user feedback issues (avg: $avg_feedback)")
    fi
    
    if [[ ${#recommendations[@]} -eq 0 ]]; then
        recommendations+=("All metrics look good, minor refinements only")
    fi
    
    jq -n \
        --argjson trigger_f1 "$trigger_f1" \
        --argjson task_rate "$task_rate" \
        --argjson avg_feedback "$avg_feedback" \
        --argjson count "${#recommendations[@]}" \
        '{"trigger_f1": $trigger_f1, "task_completion_rate": $task_rate, "avg_feedback": $avg_feedback, "recommendation_count": $count, "recommendations": $recommendations}'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ $# -lt 1 ]]; then
        echo "Usage: $0 <skill_file> [force]"
        echo "Example: $0 SKILL.md true"
        exit 1
    fi
    
    local result
    result=$(should_evolve "$1" "${2:-false}")
    echo "$result"
fi
```

- [ ] **Step 2: Make executable**

Run: `chmod +x engine/evolution/evolve_decider.sh`

- [ ] **Step 3: Test decision logic**

Run: `cd /Users/lucas/Documents/Projects/skill && bash engine/evolution/evolve_decider.sh SKILL.md false 2>/dev/null`
Expected: JSON with decision and score

---

## Task 4: Create learner.sh

**Files:**
- Create: `engine/evolution/learner.sh`

- [ ] **Step 1: Create learner.sh with pattern extraction**

```bash
#!/usr/bin/env bash
# learner.sh - Extract patterns from usage data to guide optimization

source "$(dirname "${BASH_SOURCE[0]}")/../lib/bootstrap.sh"
source "${EVAL_DIR}/lib/agent_executor.sh"

LEARNER_VERSION="1.0"

PATTERNS_DIR="${EVOLUTION_USAGE_DIR}/patterns"
KNOWLEDGE_DIR="${EVOLUTION_USAGE_DIR}/knowledge"

init_learner_dirs() {
    mkdir -p "$PATTERNS_DIR" "$KNOWLEDGE_DIR"
}

learn_from_usage() {
    local skill_file="$1"
    local rounds="${2:-10}"
    
    init_learner_dirs
    
    local skill_name
    skill_name=$(basename "$skill_file" .md)
    
    local usage_summary
    usage_summary=$(source engine/evolution/usage_tracker.sh && get_usage_summary "$skill_name" "$rounds")
    
    local patterns_file="${PATTERNS_DIR}/${skill_name}_patterns.json"
    
    local trigger_f1
    trigger_f1=$(echo "$usage_summary" | jq -r '.trigger_f1')
    local task_rate
    task_rate=$(echo "$usage_summary" | jq -r '.task_completion_rate')
    
    local weak_triggers=()
    local failed_tasks=()
    
    for ((i=0; i<rounds; i++)); do
        local date
        date=$(date -v-${i}d +%Y%m%d 2>/dev/null || date -d "-${i} days" +%Y%m%d)
        local usage_file="${EVOLUTION_USAGE_DIR}/usage_${skill_name}_${date}.jsonl"
        
        [[ ! -f "$usage_file" ]] && continue
        
        while IFS= read -r line; do
            [[ -z "$line" ]] && continue
            local event_type correct
            event_type=$(echo "$line" | jq -r '.event_type')
            
            if [[ "$event_type" == "trigger" ]]; then
                correct=$(echo "$line" | jq -r '.correct')
                if [[ "$correct" == "false" ]]; then
                    local expected actual
                    expected=$(echo "$line" | jq -r '.expected_mode')
                    actual=$(echo "$line" | jq -r '.actual_mode')
                    weak_triggers+=("${expected}->${actual}")
                fi
            fi
            
            if [[ "$event_type" == "task" ]]; then
                local completed
                completed=$(echo "$line" | jq -r '.completed')
                if [[ "$completed" == "false" ]]; then
                    local task_type
                    task_type=$(echo "$line" | jq -r '.task_type')
                    failed_tasks+=("$task_type")
                fi
            fi
        done < "$usage_file"
    done
    
    local patterns
    patterns=$(jq -n \
        --arg skill "$skill_name" \
        --argjson trigger_f1 "$trigger_f1" \
        --argjson task_rate "$task_rate" \
        --argjson weak_triggers_count "${#weak_triggers[@]}" \
        --argjson failed_tasks_count "${#failed_tasks[@]}" \
        --argjson analyzed_days "$rounds" \
        '{
            skill: $skill,
            metrics: {
                trigger_f1: $trigger_f1,
                task_completion_rate: $task_rate
            },
            patterns: {
                weak_triggers: $weak_triggers,
                failed_task_types: $failed_tasks
            },
            analysis_days: $analyzed_days,
            generated_at: (now | strftime("%Y-%m-%dT%H:%M:%SZ"))
        }')
    
    echo "$patterns" > "$patterns_file"
    echo "$patterns"
}

get_improvement_hints() {
    local patterns_file="$1"
    
    local skill_name
    skill_name=$(basename "$patterns_file" _patterns.json)
    
    local patterns
    patterns=$(cat "$patterns_file")
    
    local trigger_f1
    trigger_f1=$(echo "$patterns" | jq -r '.metrics.trigger_f1')
    local task_rate
    task_rate=$(echo "$patterns" | jq -r '.metrics.task_completion_rate')
    
    local hints=[]
    
    if (( $(echo "$trigger_f1 < 0.85" | bc -l) )); then
        local weak_triggers
        weak_triggers=$(echo "$patterns" | jq -r '.patterns.weak_triggers | join(", ")')
        hints+=("Trigger confusion detected: $weak_triggers. Consider adding disambiguation examples.")
    fi
    
    if (( $(echo "$task_rate < 0.80" | bc -l) )); then
        hints+=("Task completion issues detected. Review workflow steps and error handling.")
    fi
    
    if [[ ${#hints[@]} -eq 0 ]]; then
        hints+=("No specific issues found. Continue normal optimization.")
    fi
    
    jq -n \
        --arg skill "$skill_name" \
        --argjson hint_count "${#hints[@]}" \
        '{"skill": $skill, "hint_count": $hint_count, "hints": $hints}'
}

consolidate_knowledge() {
    local skill_name="$1"
    
    init_learner_dirs
    
    local patterns_file="${PATTERNS_DIR}/${skill_name}_patterns.json"
    local knowledge_file="${KNOWLEDGE_DIR}/${skill_name}_knowledge.md"
    
    if [[ ! -f "$patterns_file" ]]; then
        echo "# Knowledge for $skill_name\n\nNo data yet." > "$knowledge_file"
        return
    fi
    
    local patterns
    patterns=$(cat "$patterns_file")
    
    local trigger_f1
    trigger_f1=$(echo "$patterns" | jq -r '.metrics.trigger_f1')
    local task_rate
    task_rate=$(echo "$patterns" | jq -r '.metrics.task_completion_rate')
    local generated_at
    generated_at=$(echo "$patterns" | jq -r '.generated_at')
    
    cat > "$knowledge_file" << EOF
# Knowledge Consolidation: $skill_name

Generated: $generated_at

## Performance Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Trigger F1 | $trigger_f1 | $([ "$(echo "$trigger_f1 >= 0.90" | bc)" == "1" ] && echo "GOOD" || echo "NEEDS_IMPROVEMENT") |
| Task Completion | $task_rate | $([ "$(echo "$task_rate >= 0.85" | bc)" == "1" ] && echo "GOOD" || echo "NEEDS_IMPROVEMENT") |

## Usage Patterns

### Weak Triggers
$(echo "$patterns" | jq -r '.patterns.weak_triggers | if length > 0 then . | to_entries | .[].value | "- \(.)" else "- None detected" end')

### Failed Task Types
$(echo "$patterns" | jq -r '.patterns.failed_task_types | if length > 0 then . | to_entries | .[].value | "- \(.)" else "- None detected" end')

## Recommendations

$(get_improvement_hints "$patterns_file" | jq -r '.hints | to_entries | .[].value | "- \(.value)"')
EOF
    
    echo "$knowledge_file"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Learner v${LEARNER_VERSION}"
    echo "Usage: source learner.sh and call learn_from_usage, get_improvement_hints, consolidate_knowledge"
fi
```

- [ ] **Step 2: Make executable**

Run: `chmod +x engine/evolution/learner.sh`

- [ ] **Step 3: Test pattern learning**

Run: `cd /Users/lucas/Documents/Projects/skill && bash -c 'source engine/evolution/learner.sh && learn_from_usage SKILL.md 7' 2>/dev/null`
Expected: JSON patterns output

---

## Task 5: Modify engine.sh to integrate new components

**Files:**
- Modify: `engine/evolution/engine.sh:1-60` and add new steps

- [ ] **Step 1: Add source statements after line 11**

After `require_evolution rollback _storage`, add:

```bash
source "$(dirname "${BASH_SOURCE[0]}")/usage_tracker.sh"
source "$(dirname "${BASH_SOURCE[0]}")/evolve_decider.sh"
source "$(dirname "${BASH_SOURCE[0]}")/learner.sh"
```

- [ ] **Step 2: Modify evolve_skill function to accept usage context (lines 49-61)**

Replace the evolve_skill function header and initial setup to add usage_context parameter:

```bash
evolve_skill() {
    local skill_file="$1"
    local max_rounds="${2:-20}"
    local usage_context="${3:-}"
    
    init_results_tsv
    
    local skill_name
    skill_name=$(basename "$skill_file" .md)
    
    log_evolution "$skill_name" "start" "9-step evolution cycle started with usage learning (max $max_rounds rounds)"
    
    local old_score
    old_score=$(evaluate_skill "$skill_file" "fast" | jq -r '.total_score // 0')
    
    local patterns=""
    if [[ -n "$usage_context" ]]; then
        patterns=$(learn_from_usage "$skill_file" 7)
        log_evolution "$skill_name" "patterns_learned" "$patterns"
    fi
```

- [ ] **Step 3: Add Step 0 - Usage Analysis at line 67 (inside while loop, before STEP 1)**

After `while [[ $current_round -lt $max_rounds ]]; do` and before the STEP 1 echo, add:

```bash
        if [[ $current_round -eq 1 ]] && [[ -n "$patterns" ]]; then
            echo ""
            echo "=== STEP 0: USAGE ANALYSIS (Learn from Usage Data) ==="
            local hints
            hints=$(get_improvement_hints "${PATTERNS_DIR}/${skill_name}_patterns.json")
            echo "  Improvement hints from usage:"
            echo "$hints" | jq -r '.hints | to_entries | .[].value | "  - \(.value)"'
            consolidate_knowledge "$skill_name"
        fi
```

- [ ] **Step 4: Add CURATION step call with usage context (around line 97-101)**

Replace the CURATION section with:

```bash
        if [[ $current_round % 10 -eq 1 ]]; then
            echo ""
            echo "=== STEP 3: CURATION (Every 10 Rounds + Usage) ==="
            curation_knowledge "$skill_name"
            if [[ -n "$patterns" ]]; then
                consolidate_knowledge "$skill_name"
            fi
        fi
```

- [ ] **Step 5: Track evolution results in usage data**

After line 167 (`echo "$current_round\t$weakest_dim\t$old_score\t$new_score\t..."`), add:

```bash
        track_task "$skill_name" "evolution_round" "$([ "$delta" > 0 ] && echo "true" || echo "false")" "$current_round"
```

- [ ] **Step 6: Update evolve_with_auto trigger section in main block (lines 539-553)**

Add at end of file before the final `fi`:

```bash
evolve_with_auto() {
    local skill_file="$1"
    local force="${2:-false}"
    
    local decision
    decision=$(should_evolve "$skill_file" "$force")
    
    local decision_type
    decision_type=$(echo "$decision" | jq -r '.decision')
    
    if [[ "$decision_type" != "evolve" ]]; then
        echo "Evolution skipped: $(echo "$decision" | jq -r '.reason')"
        return 0
    fi
    
    echo "Evolution triggered: $(echo "$decision" | jq -r '.reason')"
    update_last_check
    
    evolve_skill "$skill_file" 20 "with_usage"
}
```

- [ ] **Step 7: Update the main block to support auto mode (lines 539-552)**

Replace the main block with:

```bash
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ $# -lt 1 ]]; then
        echo "Usage: $0 <skill_file> [max_rounds] [auto]"
        echo "  auto mode: $0 <skill_file> auto [force]"
        exit 1
    fi
    
    if [[ "${2:-}" == "auto" ]]; then
        acquire_lock "evolution" "$EVOLUTION_TIMEOUT" || {
            echo "Error: Failed to acquire evolution lock"
            exit 1
        }
        trap "release_lock 'evolution'" EXIT
        evolve_with_auto "$1" "${3:-false}"
    else
        acquire_lock "evolution" "$EVOLUTION_TIMEOUT" || {
            echo "Error: Failed to acquire evolution lock"
            exit 1
        }
        trap "release_lock 'evolution'" EXIT
        evolve_skill "$1" "${2:-20}" ""
    fi
fi
```

---

## Task 6: Update SKILL.md with §6 Self-Evolution

**Files:**
- Modify: `SKILL.md` - Add new section at end

- [ ] **Step 1: Add §6 Self-Evolution section before final EOF**

At the end of SKILL.md (after line 870), add:

```markdown
---

## §6 Self-Evolution (Use-Then-Evolve)

### 6.1 Trigger Mechanisms

**Dual Trigger System**:

| Trigger | Condition | Priority |
|---------|-----------|----------|
| **Threshold** | Score < GOLD (475) | High |
| **Scheduled** | Every 24 hours | Medium |
| **Usage-based** | Trigger F1 < 0.85 OR Task Rate < 0.80 | High |
| **Manual** | `evolve_with_auto` called with force=true | Highest |

**Decision Flow**:
```
check_threshold() → check_scheduled() → check_usage_metrics() → decision
```

### 6.2 Usage Data Collection

**Tracked Events**:

| Event | Fields | Storage |
|-------|--------|---------|
| `trigger` | expected_mode, actual_mode, correct | logs/evolution/usage_<skill>_<date>.jsonl |
| `task` | task_type, completed, rounds | logs/evolution/usage_<skill>_<date>.jsonl |
| `feedback` | rating (1-5), comment | logs/evolution/usage_<skill>_<date>.jsonl |

**Metrics Computed**:
- **Trigger F1**: correct_triggers / total_triggers
- **Task Completion Rate**: completed_tasks / total_tasks
- **Avg Feedback Rating**: mean of all ratings

### 6.3 Usage-Triggered Evolution

**Enhanced 9-Step Loop with Step 0**:

| Step | Name | Description |
|------|------|-------------|
| 0 | **USAGE_ANALYSIS** | Extract patterns from usage data (NEW) |
| 1 | READ | Locate weakest dimension (multi-LLM) |
| 2 | ANALYZE | Prioritize strategy (multi-LLM) |
| 3 | CURATION | Knowledge consolidation + usage learning |
| 4 | PLAN | Select improvement approach |
| 5 | IMPLEMENT | Apply change with rollback |
| 6 | VERIFY | Re-evaluate with multi-LLM |
| 7 | HUMAN_REVIEW | Every 10 rounds if score < SILVER |
| 8 | LOG | Record to results.tsv + track usage |
| 9 | COMMIT | Git commit if needed |

### 6.4 Pattern Learning

**Pattern Types Extracted**:
- `weak_triggers`: Array of `expected->actual` confusion pairs
- `failed_task_types`: Array of task types with low completion

**Knowledge Consolidation**:
- Patterns stored in `logs/evolution/patterns/<skill>_patterns.json`
- Knowledge docs in `logs/evolution/knowledge/<skill>_knowledge.md`

**Improvement Hints**:
- Generated from pattern analysis
- Injected into optimization loop
- Example: "Trigger confusion: OPTIMIZE->EVALUATE. Add disambiguation examples."

### 6.5 Auto-Evolution Command

```bash
# Check if evolution needed (returns JSON decision)
engine/evolution/evolve_decider.sh <skill_file> [force]

# Run auto-evolution with usage learning
engine/evolution/engine.sh <skill_file> auto [force]

# Track usage manually
source engine/evolution/usage_tracker.sh
track_trigger "agent-skill" "OPTIMIZE" "OPTIMIZE"
track_task "agent-skill" "optimization" "true" 3
track_feedback "agent-skill" 5 "Good results"
```

### 6.6 Integration with Lean Eval

Lean evaluation (~0s, $0) runs first:
- If score >= GOLD threshold → skip expensive LLM evolution
- If score < threshold → trigger evolution
- Usage metrics provide additional trigger signals

**Threshold Configuration**:
| Tier | Score | Evolution Trigger |
|------|-------|-------------------|
| GOLD | >= 475 | Usage-based only |
| SILVER | 425-474 | Scheduled + Usage |
| BRONZE | 350-424 | All triggers |
| FAIL | < 350 | Immediate + Force |
```

---

## Verification

- [ ] **Test 1: Bootstrap new paths**
  Run: `source engine/lib/bootstrap.sh && echo $EVOLUTION_USAGE_DIR`
  Expected: `.../logs/evolution`

- [ ] **Test 2: Usage tracking**
  Run: `bash -c 'source engine/evolution/usage_tracker.sh && init_usage_file "test" && track_trigger "test" "A" "B" && get_usage_summary "test" 1'`
  Expected: JSON with trigger_f1 and stats

- [ ] **Test 3: Evolution decision**
  Run: `bash engine/evolution/evolve_decider.sh SKILL.md false 2>/dev/null`
  Expected: JSON with decision and score

- [ ] **Test 4: Pattern learning**
  Run: `bash -c 'source engine/evolution/learner.sh && learn_from_usage SKILL.md 1' 2>/dev/null`
  Expected: JSON patterns file created in logs/evolution/patterns/

- [ ] **Test 5: Integration - full evolution with usage**
  Run: `bash engine/evolution/engine.sh SKILL.md 3 with_usage 2>&1 | head -50`
  Expected: Step 0 appears in output with usage analysis

- [ ] **Test 6: Lean score still works**
  Run: `bash scripts/lean-orchestrator.sh SKILL.md SILVER 2>&1 | tail -5`
  Expected: Score and tier output

---

## Self-Review Checklist

- [ ] All new files have `#!/usr/bin/env bash` and are executable
- [ ] All sources use correct relative paths from engine/evolution/
- [ ] Functions are exported where needed for sourcing
- [ ] JSON output uses jq for parsing
- [ ] No hardcoded paths - all use variables from bootstrap.sh
- [ ] Error handling with `|| true` where appropriate
- [ ] Timestamps use `get_timestamp` from bootstrap
