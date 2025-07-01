#!/bin/zsh
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TEST_MODULE="flagtest"
TEST_ALIAS="flagtest_alias"

echo -e "${BLUE}🧪 Flag Parsing Test${NC}"
echo "====================="

# Step 1: Create config with comprehensive flags
echo -e "${YELLOW}1. Creating config...${NC}"
lie create -y $TEST_MODULE

# Step 2: Replace with expected config
echo -e "${YELLOW}2. Replacing with expected config...${NC}"
cat > "${TEST_MODULE}.json" <<EOF
{
    "name": "$TEST_MODULE",
    "description": "Comprehensive flag test module",
    "alias": "$TEST_ALIAS",
    "commands": [
        {
            "name": "flags",
            "description": "Test all flag scenarios",
            "flags": [
                { "name": "env", "shorthand": "e", "description": "Environment (value)" },
                { "name": "force", "shorthand": "f", "description": "Force (boolean)" },
                { "name": "dry-run", "shorthand": "d", "description": "Dry run (boolean)" },
                { "name": "count", "shorthand": "c", "description": "Count (value)" },
                { "name": "verbose", "shorthand": "v", "description": "Verbose (boolean)" },
                { "name": "no-color", "shorthand": "", "description": "Disable color (boolean)" }
            ]
        }
    ]
}
EOF

# Step 3: Generate package
echo -e "${YELLOW}3. Generating package...${NC}"
lie package $TEST_MODULE

# Step 4: Replace commands.sh with test responses
echo -e "${YELLOW}4. Replacing commands.sh...${NC}"
cat > "${TEST_MODULE}_cli/commands.sh" <<'EOF'
#!/bin/zsh

flags() {
    local env=""
    local force=""
    local dry_run=""
    local count=""
    local verbose=""
    local no_color=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -e|--env)
                env="$2"; shift 2;;
            -f|--force)
                force="true"; shift;;
            -d|--dry-run)
                dry_run="true"; shift;;
            -c|--count)
                count="$2"; shift 2;;
            -v|--verbose)
                verbose="true"; shift;;
            --no-color)
                no_color="true"; shift;;
            *) break;;
        esac
    done
    
    echo "env=$env force=$force dry_run=$dry_run count=$count verbose=$verbose no_color=$no_color"
}

help() {
    echo "Available: flags, help"
}
EOF

# Step 5: Install
echo -e "${YELLOW}5. Installing...${NC}"
cd "${TEST_MODULE}_cli"
./install.sh
cd ..

# Step 6: Test each command with flags
echo -e "${YELLOW}6. Testing commands...${NC}"

# Test all flags, long form
output=$($TEST_ALIAS flags --env prod --force --dry-run --count 5 --verbose --no-color)
expected="env=prod force=true dry_run=true count=5 verbose=true no_color=true"
if [ "$output" = "$expected" ]; then
    echo -e "${GREEN}✅ All flags (long form)${NC}"
else
    echo -e "${RED}❌ All flags (long form): expected '$expected', got '$output'${NC}"
    exit 1
fi

# Test all flags, short form
output=$($TEST_ALIAS flags -e dev -f -d -c 3 -v)
expected="env=dev force=true dry_run=true count=3 verbose=true no_color="
if [ "$output" = "$expected" ]; then
    echo -e "${GREEN}✅ All flags (short form)${NC}"
else
    echo -e "${RED}❌ All flags (short form): expected '$expected', got '$output'${NC}"
    exit 1
fi

# Test mixed order
output=$($TEST_ALIAS flags --force -e qa --count 7 -d)
expected="env=qa force=true dry_run=true count=7 verbose= no_color="
if [ "$output" = "$expected" ]; then
    echo -e "${GREEN}✅ Mixed order flags${NC}"
else
    echo -e "${RED}❌ Mixed order flags: expected '$expected', got '$output'${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 All flag parsing tests passed!${NC}" 