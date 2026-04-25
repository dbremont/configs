
import subprocess
import sys
import os
from openai import OpenAI

def get_git_diff():
    """Gets the git diff for staged changes."""
    try:
        result = subprocess.check_output(["git", "diff", "--staged"], stderr=subprocess.STDOUT)
        return result.decode("utf-8").strip()
    except subprocess.CalledProcessError as e:
        output = e.output.decode("utf-8")
        if "no changes added" in output.lower() or "does not have any commits yet" in output.lower():
            return None
        print(f"Git error: {output}")
        sys.exit(1)

def generate_commit_message(diff):
    """Uses OpenAI SDK to call Zhipu AI (Z.ai) API."""
    
    # Initialize the OpenAI client pointing to Zhipu's endpoint
    client = OpenAI(
        api_key=os.environ.get("ZHIPUAI_API_KEY"), # Use your Zhipu Key
        base_url="https://api.z.ai/api/paas/v4/" # Zhipu's OpenAI-compatible URL
    )

    if not diff:
        return "No changes detected to generate a message."

    prompt = f"""
    Write a concise, beautiful, and semantic Git commit message for the following code changes.
    Follow the Conventional Commits specification (e.g., 'feat:', 'fix:', 'refactor:').
    
    Diff:
    {diff}
    """

    try:
        # You can use "glm-4-flash" (fast/cheap) or "glm-4" (smart)
        response = client.chat.completions.create(
            model="glm-4.6", 
            messages=[
                {"role": "system", "content": "You are an expert software engineer who writes perfect git commit messages."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.7,
        )
        return response.choices[0].message.content.strip()
    except Exception as e:
        return f"Error calling Z.ai API via OpenAI SDK: {str(e)}"

if __name__ == "__main__":
    # Ensure ZHIPUAI_API_KEY is set
    if not os.environ.get("ZHIPUAI_API_KEY"):
        print("Error: Please set the ZHIPUAI_API_KEY environment variable.")
        sys.exit(1)

    print("🔍 Analyzing staged changes...")
    diff_content = get_git_diff()

    if diff_content:
        message = generate_commit_message(diff_content)
        print("\n" + "="*40)
        print("💡 Suggested Commit Message (Z.ai):")
        print("="*40)
        print(message)
        print("="*40 + "\n")
    else:
        print("No staged changes found. (Try 'git add .' first)")
