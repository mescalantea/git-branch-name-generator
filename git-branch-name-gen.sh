#!/bin/bash
# Colors for the output
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
WHITE=$(tput setaf 7)
NC=$(tput sgr0) # No color
# Function to validate if the issue type is valid
function validate_issue_type() {
    issue_type=$1
    case $issue_type in
        F|B|R|H|D|E)
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

# Function to generate the branch name
function generate_branch_name() {

    issue_type=$1

    # Replace F with feature, B with bugfix, R with release, H with hotfix, D with docs, E with refactor
    case $issue_type in
        F)
            issue_type="feature"
            ;;
        B)
            issue_type="bugfix"
            ;;
        R)
            issue_type="release"
            ;;
        H)
            issue_type="hotfix"
            ;;
        D)
            issue_type="docs"
            ;;
        E)
            issue_type="refactor"
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
    issue_name=$(echo "$issue_name" | iconv -f utf-8 -t ascii//TRANSLIT | tr -cd '[:alnum:]-' |  tr ' ' '-')

    # Concatenates the fields to form the branch name
    branch_name="${issue_type}/${issue_id}${issue_name}"

    echo "$branch_name"
}

# Wizard to generate branch names
echo "${YELLOW}Git Branch Name Generator"
echo "-------------------------${NC}"

# Ask for the issue type
issue_type=$(read_input "Enter the issue type (${YELLOW}F${NC} for Feature, ${YELLOW}B${NC} for Bugfix, ${YELLOW}R${NC} for Release, ${YELLOW}H${NC} for Hotfix, ${YELLOW}D${NC} for Docs, ${YELLOW}E${NC} for Refactor): " "F")
# Validate the issue type
until validate_issue_type "$issue_type"; do
    issue_type=$(read_input "${RED}Invalid input. Please enter a valid issue type: ${NC}" "F")
done

# Ask for the issue ID
issue_id=$(read_input "Enter the issue ID or leave it blank: " "")
# Validate the issue ID
until validate_issue_id "$issue_id"; do
    issue_id=$(read_input "${RED}Invalid input. Please enter a valid issue ID: ${NC}" "")
done

# Ask for the issue name
issue_name=$(read_input "Enter the issue name: " "")

# Generate the branch name
branch_name=$(generate_branch_name "$issue_type" "$issue_id" "$issue_name")

echo "${GREEN}Generated branch name:${YELLOW} $branch_name${NC}"

# Checkout to the new branch now?
checkout=$(read_input "Do you want to checkout to the new branch now? (${YELLOW}y${NC}/${YELLOW}n${NC}): " "y")
if [ "$checkout" == "y" ]; then
    git checkout -b "$branch_name"
fi
