import streamlit as st
import requests
import os
from dotenv import load_dotenv

st.set_page_config(page_title="AnyTicket Support Assistant", page_icon="🎟️")
st.title("AnyTicket – AI Customer Support")

# Show intro only if no messages have been sent yet
if "intro_shown" not in st.session_state:
    st.session_state["intro_shown"] = True

if st.session_state.get("intro_shown", True):
    st.markdown(
        """
👋 Welcome to **AnyTicket's AI Support Assistant**! 🎟️

I can help you with event information, manage your orders, and even purchase tickets. Go ahead and tell me what you need.

For example, you can try:

- "Find rock concerts in July."
- "What's the status of my last order?"
- "Help me buy two tickets for the Rock Concert in New Yor this Friday."

_This demo features an AI Agent powered by AWS Bedrock. It's built to handle tasks from start to finish, providing a helpful, secure, and interactive experience._
"""
    )

load_dotenv()
API_URL = os.environ["API_URL"]
api_key = os.environ["API_KEY"]
origin_verify = os.environ["ORIGIN_VERIFY"]

if "messages" not in st.session_state:
    st.session_state["messages"] = []
if "session_id" not in st.session_state:
    st.session_state["session_id"] = "01978b19-0529-72e9-94ca-842c98349b6d"


def send_message():
    user_input = st.session_state["user_input"]
    if user_input.strip():
        payload = {"input": user_input}
        if st.session_state["session_id"]:
            payload["sessionId"] = st.session_state["session_id"]
        headers = {"Content-Type": "application/json"}
        if api_key:
            headers["x-api-key"] = api_key
        if origin_verify:
            headers["x-origin-verify"] = origin_verify
        try:
            resp = requests.post(API_URL, json=payload, headers=headers)
            if resp.status_code == 200:
                data = resp.json()
                answer = data.get("answer", "[No answer returned]")
                st.session_state["session_id"] = data.get(
                    "sessionId", st.session_state["session_id"]
                )
                st.session_state["messages"].append((user_input, answer))
                st.session_state["user_input"] = ""
                st.session_state["intro_shown"] = False  # Hide intro after first send
            else:
                st.session_state["messages"].append(
                    (user_input, f"[Error {resp.status_code}]: {resp.text}")
                )
                st.session_state["intro_shown"] = False
        except Exception as e:
            st.session_state["messages"].append((user_input, f"[Exception]: {e}"))
            st.session_state["intro_shown"] = False


user_input = st.text_input(
    "You:", "", key="user_input", autocomplete="off", on_change=send_message
)

if st.session_state["messages"]:
    st.markdown("---")
    for i, (q, a) in enumerate(reversed(st.session_state["messages"])):
        st.markdown(f"**😀:** {q}")
        st.markdown(f"**🤖:** {a}")
        st.markdown("---")
