#!/bin/zsh
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

MODULE="test_module"
ALIAS="test_alias"

echo -e "${BLUE}🧪 Simple Comprehensive Test${NC}"
echo "================================"

# Step 1: Use expected config directly
echo -e "${YELLOW}1. Using expected config...${NC}"
cp ../expected_test_config.json "${MODULE}.json"

if [ ! -f "${MODULE}.json" ]; then
    echo -e "${RED}❌ Config file not created${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Config ready${NC}"

# Step 2: Generate package
echo -e "${YELLOW}2. Generating package...${NC}"
lie package $MODULE

if [ ! -d "${MODULE}_cli" ]; then
    echo -e "${RED}❌ Package not generated${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Package generated${NC}"

# Step 3: Replace commands.sh with test responses
echo -e "${YELLOW}3. Replacing commands.sh...${NC}"
cat > "${MODULE}_cli/commands.sh" <<'EOF'
#!/bin/zsh

deploy() {
    local env=""
    local force=""
    local dry_run=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -e|--env)
                env="$2"; shift 2;;
            -f|--force)
                force="true"; shift;;
            -d|--dry-run)
                dry_run="true"; shift;;
            *) break;;
        esac
    done
    
    echo "deploy command with env=$env force=$force dry_run=$dry_run"
}

build() {
    local production=""
    local verbose=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--production)
                production="true"; shift;;
            -v|--verbose)
                verbose="true"; shift;;
            *) break;;
        esac
    done
    
    echo "build command with production=$production verbose=$verbose"
}

test() {
    echo "test command with no flags"
}

help() {
    echo "Available: deploy, build, test, help"
}
EOF

echo -e "${GREEN}✅ Commands.sh replaced${NC}"

# Step 4: Install
echo -e "${YELLOW}4. Installing...${NC}"
cd "${MODULE}_cli"
./install.sh
cd ..

echo -e "${GREEN}✅ Installed${NC}"

# Step 5: Test each command with flags
echo -e "${YELLOW}5. Testing commands...${NC}"

# Test deploy with various flag combinations
output=$($ALIAS deploy)
expected="deploy command with env= force= dry_run="
if [ "$output" = "$expected" ]; then
    echo -e "${GREEN}✅ deploy (no flags)${NC}"
else
    echo -e "${RED}❌ deploy (no flags): expected '$expected', got '$output'${NC}"
    exit 1
fi

output=$($ALIAS deploy --env prod)
expected="deploy command with env=prod force= dry_run="
if [ "$output" = "$expected" ]; then
    echo -e "${GREEN}✅ deploy (--env)${NC}"
else
    echo -e "${RED}❌ deploy (--env): expected '$expected', got '$output'${NC}"
    exit 1
fi

output=$($ALIAS deploy -e staging -f -d)
expected="deploy command with env=staging force=true dry_run=true"
if [ "$output" = "$expected" ]; then
    echo -e "${GREEN}✅ deploy (multiple flags)${NC}"
else
    echo -e "${RED}❌ deploy (multiple flags): expected '$expected', got '$output'${NC}"
    exit 1
fi

# Test build with flags
output=$($ALIAS build --production --verbose)
expected="build command with production=true verbose=true"
if [ "$output" = "$expected" ]; then
    echo -e "${GREEN}✅ build (both flags)${NC}"
else
    echo -e "${RED}❌ build (both flags): expected '$expected', got '$output'${NC}"
    exit 1
fi

# Test simple command
output=$($ALIAS test)
expected="test command with no flags"
if [ "$output" = "$expected" ]; then
    echo -e "${GREEN}✅ test (no flags)${NC}"
else
    echo -e "${RED}❌ test (no flags): expected '$expected', got '$output'${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 All tests passed!${NC}" 