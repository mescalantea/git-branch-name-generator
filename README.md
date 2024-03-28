# Git Branch Name Generator
Script for generate a valid branch name for using in Git. The name is composed by three elements:
1. The type of the issue (F for Feature, B for Bug, R for Refactor, H for Hotfix).
2. The issue ID on your favorite tracking system (Jira or similar options).
3. The issue title.

The output will be similar to:
```
F/ID-001-Add-a-new-amazing-feature
```