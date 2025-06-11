import streamlit as st
import requests
import os
from dotenv import load_dotenv

st.set_page_config(page_title="AnyTicket Support Assistant", page_icon="🎟️")
st.title("AnyTicket – AI Customer Support")

st.markdown(
    """
Welcome to **AnyTicket's AI Support Assistant**! 🎟️

Ask anything about your event tickets, orders, or our services. Our intelligent assistant is here to help you 24/7 with fast, friendly, and accurate answers—powered by AWS Bedrock and Retrieval-Augmented Generation (RAG).

_This demo showcases a production-grade GenAI solution with secure, contextual Q&A from diverse data sources. Built for reliability, safety, and a great customer experience._
"""
)

load_dotenv()
API_URL = os.getenv("API_URL", "https://d2eq9h0ho1qjzk.cloudfront.net/chat")
api_key = os.getenv("API_KEY", "")
origin_verify = os.getenv("ORIGIN_VERIFY", "")

if "messages" not in st.session_state:
    st.session_state["messages"] = []
if "session_id" not in st.session_state:
    st.session_state["session_id"] = None

user_input = st.text_input("You:", "", key="user_input")

if st.button("Send") and user_input.strip():
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
        else:
            st.session_state["messages"].append(
                (user_input, f"[Error {resp.status_code}]: {resp.text}")
            )
    except Exception as e:
        st.session_state["messages"].append((user_input, f"[Exception]: {e}"))

if st.session_state["messages"]:
    st.markdown("---")
    for i, (q, a) in enumerate(reversed(st.session_state["messages"])):
        st.markdown(f"**You:** {q}")
        st.markdown(f"**Bot:** {a}")
        st.markdown("---")
