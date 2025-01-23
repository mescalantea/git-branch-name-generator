#!/bin/bash
# Colors for the output
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
WHITE=$(tput setaf 7)
CYAN=$(tput setaf 6)
NC=$(tput sgr0) # No color
# Function to validate if the issue type is valid
function validate_issue_type() {
    issue_type=$1
    case $issue_type in
        a|b|c|d|e|f|h|r|s)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Función para manejar la entrada de usuario de manera genérica
read_input() {
    local message="$1" # Message to show to the user
    local default="$2"  # Default value to show in the input (only works in Linux)

    if [[ "$OSTYPE" == "darwin"* || "$default" == "" ]]; then
        # macOS does not support the -i option in the read command
        read -e -p "$message" input_value
    else
        read -e -p "$message" -i "$default" input_value
    fi

    # Devolver el valor ingresado por el usuario
    echo "$input_value"
}

# Function to validate if the issue ID is valid
function validate_issue_id() {
    issue_id=$1
    # Verifies if the issue ID contains only alphanumeric characters and hyphens
    if [[ -z $issue_id || $issue_id =~ ^[[:alnum:]-]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to validate if the issue name is valid
function validate_issue_name() {
    issue_name=$1
    if [[ -n $issue_name ]]; then
        return 0
    else
        return 1
    fi
}

# Function to generate the branch name
function generate_branch_name() {

    issue_type=$1

    # Replace F with feature, B with bugfix, R with release, H with hotfix, D with docs, E with refactor
    case $issue_type in
        a)
            issue_type="refactor"
            ;;
        b)
            issue_type="bugfix"
            ;;
        c)
            issue_type="chore"
            ;;
        d)
            issue_type="docs"
            ;;
        e)
            issue_type="experiment"
            ;;
        f)
            issue_type="feature"
            ;;
        h)
            issue_type="hotfix"
            ;;
        r)
            issue_type="release"
            ;;
        s)
            issue_type="support"
            ;;
    esac

    issue_id=""
    if [ -n "$2" ]; then
        issue_id=$(echo "$2" | tr '[:lower:]' '[:upper:]') # Convert to uppercase
        issue_id="${issue_id}-"
    fi
    issue_name=$3

    # Replace spaces in the issue name with hyphens
    issue_name=$(echo "$issue_name" | tr ' ' '-')

    # Replaces non-permitted characters for branch name in the issue name
    issue_name=$(echo "$issue_name" | iconv -f utf-8 -t ascii//TRANSLIT | tr -cd '[:alnum:]._/-' |  tr ' ' '-')

    # Concatenates the fields to form the branch name
    branch_name="${issue_type}/${issue_id}${issue_name}"

    echo "$branch_name"
}

# Wizard to generate branch names
echo "${NC}Git Branch Name Generator"
echo "-------------------------"

# Ask for the issue type
echo "${GREEN}Choose the issue type according your scenario:"
echo ""
echo "a) Refactor: code refactoring"
echo "b) Bugfix: fix well-known bugs"
echo "c) Chore: maintenance tasks like scripting or configuration"
echo "d) Docs: project documentation"
echo "e) Experiment: validate ideas or concepts"
echo "f) Feature: adding new features"
echo "h) Hotfix: fix critical bugs in production"
echo "r) Release: prepare a new release"
echo "s) Support: maintenance of specific versions"
echo ""

issue_type=$(read_input "${GREEN}Enter your choice (${YELLOW}a${GREEN}/${YELLOW}b${GREEN}/${YELLOW}c${GREEN}/${YELLOW}d${GREEN}/${YELLOW}e${GREEN}/${YELLOW}f${GREEN}/${YELLOW}h${GREEN}/${YELLOW}r${GREEN}/${YELLOW}s${GREEN}${GREEN}): ${YELLOW}" "f")
# Validate the issue type
until validate_issue_type "$issue_type"; do
    issue_type=$(read_input "${RED}Invalid input. Please enter a valid issue type: ${YELLOW}" "f")
done

# Ask for the issue ID
echo ""
issue_id=$(read_input "${GREEN}Enter the issue ID or leave it blank: ${YELLOW}" "")
# Validate the issue ID
until validate_issue_id "$issue_id"; do
    issue_id=$(read_input "${RED}Invalid input. Please enter a valid issue ID: ${YELLOW}" "")
done

# Ask for the issue name
echo ""
issue_name=$(read_input "${GREEN}Enter the issue name: ${YELLOW}" "")
# Validate the issue ID
until validate_issue_name "$issue_name"; do
    issue_name=$(read_input "${RED}Invalid input. Please enter a valid issue name: ${YELLOW}" "")
done

# Generate the branch name
branch_name=$(generate_branch_name "$issue_type" "$issue_id" "$issue_name")

echo ""
echo "${GREEN}Generated branch name:${CYAN} $branch_name${NC}"

# Checkout to the new branch now?
checkout=$(read_input "Do you want to checkout to the new branch now? (${YELLOW}y${NC}/${YELLOW}n${NC}): " "y")
if [ "$checkout" == "y" ]; then
    git checkout -b "$branch_name"
fi
