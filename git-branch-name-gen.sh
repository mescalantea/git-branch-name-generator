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
        F|B|R|H)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Function to validate if the issue ID is valid
function validate_issue_id() {
    issue_id=$1
    # Verifies if the issue ID contains only alphanumeric characters and hyphens
    if [[ $issue_id =~ ^[[:alnum:]-]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to generate the branch name
function generate_branch_name() {
    issue_type=$1
    issue_id=$(echo "$2" | tr '[:lower:]' '[:upper:]') # Convert to uppercase
    issue_name=$3

    # Replace spaces in the issue name with hyphens
    issue_name=$(echo "$issue_name" | tr ' ' '-')

    # Replaces non-permitted characters for branch name in the issue name
    issue_name=$(echo "$issue_name" | iconv -f utf-8 -t ascii//TRANSLIT | tr -cd '[:alnum:]-' |  tr ' ' '-')

    # Concatenates the fields to form the branch name
    branch_name="${issue_type}/${issue_id}-${issue_name}"

    echo "$branch_name"
}

# Wizard to generate branch names
echo "${YELLOW}Git Branch Name Generator"
echo "-------------------------${NC}"

# Ask for the issue type
read -p "Enter the issue type (${YELLOW}F${NC} for Feature, ${YELLOW}B${NC} for Bug, ${YELLOW}R${NC} for Refactor, ${YELLOW}H${NC} for Hotfix):${NC} " issue_type
# Validate the issue type
until validate_issue_type "$issue_type"; do
    read -p "${RED}Invalid input. Please enter a valid issue type (${YELLOW}F${NC}, ${YELLOW}B${NC}, ${YELLOW}R${NC}, ${YELLOW}H${NC}):${NC} " issue_type
done

# Ask for the issue ID
read -p "Enter the issue ID: " issue_id
# Validate the issue ID
until validate_issue_id "$issue_id"; do
    read -p "${RED}Invalid input. Please enter a valid issue ID:${NC} " issue_id
done

# Ask for the issue name
read -p "Enter the issue name: " issue_name

# Generate the branch name
branch_name=$(generate_branch_name "$issue_type" "$issue_id" "$issue_name")

echo "${GREEN}Generated branch name:${YELLOW} $branch_name${NC}"

# Checkout to the new branch now?
read -p "Do you want to checkout to the new branch now? (${YELLOW}y${NC}/${YELLOW}n${NC}): " checkout
if [ "$checkout" == "y" ]; then
    git checkout -b "$branch_name"
fi