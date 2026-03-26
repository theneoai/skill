# 9-Step Optimization Loop

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                     AUTONOMOUS OPTIMIZATION LOOP (9 STEPS)                   │
└──────────────────────────────────────────────────────────────────────────────┘

     ┌─────────┐
     │  START  │
     └────┬────┘
          │
          ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  1. READ        │────▶│  2. ANALYZE     │────▶│  3. CURATION    │
│  - Run score.sh │     │  - Identify     │     │  - Consolidate  │
│  - Get baseline │     │    weakest dim  │     │    knowledge    │
└─────────────────┘     └─────────────────┘     │  - Remove       │
                                                │    redundant    │
                                                └────────┬────────┘
                                                         │
                                                         ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  9. COMMIT      │◀────│  8. LOG         │◀────│  4. PLAN        │
│  - Git commit   │     │  - Record       │     │  - Select       │
│    every 10x    │     │    results.tsv  │     │    strategy     │
└─────────────────┘     └─────────────────┘     └────────┬────────┘
          │                                              │
          │                       ┌──────────────────────┘
          │                       │
          ▼                       ▼
┌──────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  7. HUMAN_       │────▶│  6. VERIFY      │────▶│  5. IMPLEMENT   │
│  REVIEW (opt)    │     │  - Check        │     │  - Apply fix    │
│  - Expert review │     │    variance     │     │  - Atomic       │
│    if score<8.0  │     │  - Dual-track   │     │    change       │
└──────────────────┘     └─────────────────┘     └─────────────────┘

Legend:
  ★ CURATION: Prevents context collapse (ACE Framework)
  ★ HUMAN_REVIEW: Required when score < 8.0 after 10 rounds (c-CRAB)
  ★ COMMIT: Every 10 rounds for checkpoint recovery
```
