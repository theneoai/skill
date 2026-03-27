#!/usr/bin/env bash
# constants.sh — 统一质量目标常量
# 版本: 1.0.0
# 解决: 评分脚本中常量分散、版本不一致问题
#
# 用法: source constants.sh

# ═══════════════════════════════════════════════════════════════════════════════
# 认证阈值 (4档体系)
# ═══════════════════════════════════════════════════════════════════════════════

# PLATINUM — 精英档
readonly THRESHOLD_PLATINUM_TEXT=9.5
readonly THRESHOLD_PLATINUM_RUNTIME=9.5
readonly THRESHOLD_PLATINUM_VARIANCE=1.0

# GOLD — 优秀档
readonly THRESHOLD_GOLD_TEXT=9.0
readonly THRESHOLD_GOLD_RUNTIME=9.0
readonly THRESHOLD_GOLD_VARIANCE=1.5

# SILVER — 良好档
readonly THRESHOLD_SILVER_TEXT=8.0
readonly THRESHOLD_SILVER_RUNTIME=8.0
readonly THRESHOLD_SILVER_VARIANCE=2.0

# BRONZE — 入门档
readonly THRESHOLD_BRONZE_TEXT=7.0
readonly THRESHOLD_BRONZE_RUNTIME=7.0
readonly THRESHOLD_BRONZE_VARIANCE=3.0

# 兼容旧版
readonly SCORE_CERTIFIED=8.5
readonly SCORE_EXEMPLARY=9.5

# ═══════════════════════════════════════════════════════════════════════════════
# 方差阈值
# ═══════════════════════════════════════════════════════════════════════════════

readonly VARIANCE_EXCELLENT=1.0
readonly VARIANCE_GOOD=1.5
readonly VARIANCE_MODERATE=2.0
readonly VARIANCE_CRITICAL=3.0

# ═══════════════════════════════════════════════════════════════════════════════
# 模式检测阈值
# ═══════════════════════════════════════════════════════════════════════════════

readonly MODE_DETECTION_TARGET=0.95
readonly MODE_DETECTION_MIN=0.60

# ═══════════════════════════════════════════════════════════════════════════════
# 运行时验证权重
# ═══════════════════════════════════════════════════════════════════════════════

readonly RUNTIME_WEIGHT_TRIGGER=0.20
readonly RUNTIME_WEIGHT_MODE=0.30
readonly RUNTIME_WEIGHT_QUALITY=0.30
readonly RUNTIME_WEIGHT_ACCURACY=0.20

# ═══════════════════════════════════════════════════════════════════════════════
# 循环控制
# ═══════════════════════════════════════════════════════════════════════════════

readonly MAX_ROUNDS=100
readonly CURATION_INTERVAL=10
readonly NO_IMPROVEMENT_LIMIT=5

# ═══════════════════════════════════════════════════════════════════════════════
# 指标目标
# ═══════════════════════════════════════════════════════════════════════════════

readonly F1_TARGET=0.90
readonly MRR_TARGET=0.85
readonly MULTI_TURN_TARGET=85
readonly TRACE_COMPLIANCE_TARGET=0.90

# ═══════════════════════════════════════════════════════════════════════════════
# 导出常量供其他脚本使用
# ═══════════════════════════════════════════════════════════════════════════════

export THRESHOLD_PLATINUM_TEXT THRESHOLD_PLATINUM_RUNTIME THRESHOLD_PLATINUM_VARIANCE
export THRESHOLD_GOLD_TEXT THRESHOLD_GOLD_RUNTIME THRESHOLD_GOLD_VARIANCE
export THRESHOLD_SILVER_TEXT THRESHOLD_SILVER_RUNTIME THRESHOLD_SILVER_VARIANCE
export THRESHOLD_BRONZE_TEXT THRESHOLD_BRONZE_RUNTIME THRESHOLD_BRONZE_VARIANCE
export VARIANCE_EXCELLENT VARIANCE_GOOD VARIANCE_MODERATE VARIANCE_CRITICAL
export MODE_DETECTION_TARGET MODE_DETECTION_MIN
export RUNTIME_WEIGHT_TRIGGER RUNTIME_WEIGHT_MODE RUNTIME_WEIGHT_QUALITY RUNTIME_WEIGHT_ACCURACY
export MAX_ROUNDS CURATION_INTERVAL NO_IMPROVEMENT_LIMIT
export F1_TARGET MRR_TARGET MULTI_TURN_TARGET TRACE_COMPLIANCE_TARGET
