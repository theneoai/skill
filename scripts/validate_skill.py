import sys
from pathlib import Path
import yaml

def validate_skill(skill_dir: str):
    md_file = Path(skill_dir) / "SKILL.md"
    if not md_file.exists():
        print("❌ SKILL.md 文件不存在")
        sys.exit(1)
    
    with open(md_file, encoding="utf-8") as f:
        content = f.read()
    
    if not content.startswith("---"):
        print("❌ SKILL.md 缺少 YAML Frontmatter")
        sys.exit(1)
    
    try:
        yaml_part = content.split("---")[1]
        metadata = yaml.safe_load(yaml_part)
        if not metadata.get("name") or not metadata.get("description"):
            print("❌ name 和 description 为必填字段")
            sys.exit(1)
    except Exception:
        print("❌ YAML 格式解析失败")
        sys.exit(1)
    
    print(f"✅ {skill_dir} 符合 agentskills.io 开放标准")
    print(f"   Skill Name: {metadata.get('name')}")
    print(f"   Version: {metadata.get('metadata', {}).get('version', 'unknown')}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python validate_skill.py <skill_directory>")
        sys.exit(1)
    validate_skill(sys.argv[1])
