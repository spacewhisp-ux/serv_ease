#!/bin/bash

BASE_URL="http://localhost:3001/v1"

echo "========================================="
echo "Serv Ease Backend API Validation"
echo "========================================="
echo ""

echo "1. Registering test user..."
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123456",
    "displayName": "Test User"
  }')

echo "$REGISTER_RESPONSE" | jq '.'

USER_ACCESS_TOKEN=$(echo "$REGISTER_RESPONSE" | jq -r '.data.accessToken // empty')
USER_REFRESH_TOKEN=$(echo "$REGISTER_RESPONSE" | jq -r '.data.refreshToken // empty')

if [ -z "$USER_ACCESS_TOKEN" ]; then
  echo "User already exists, trying to login..."
  LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
    -H "Content-Type: application/json" \
    -d '{
      "account": "test@example.com",
      "password": "Test123456"
    }')
  echo "$LOGIN_RESPONSE" | jq '.'
  USER_ACCESS_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.data.accessToken')
  USER_REFRESH_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.data.refreshToken')
fi

echo ""
echo "2. Creating a ticket..."
CREATE_TICKET_RESPONSE=$(curl -s -X POST "$BASE_URL/tickets" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $USER_ACCESS_TOKEN" \
  -d '{
    "subject": "Test Ticket",
    "description": "This is a test ticket for validation",
    "priority": "NORMAL",
    "category": "GENERAL"
  }')

echo "$CREATE_TICKET_RESPONSE" | jq '.'
TICKET_ID=$(echo "$CREATE_TICKET_RESPONSE" | jq -r '.data.id')

echo ""
echo "3. Listing tickets..."
LIST_TICKETS_RESPONSE=$(curl -s -X GET "$BASE_URL/tickets" \
  -H "Authorization: Bearer $USER_ACCESS_TOKEN")

echo "$LIST_TICKETS_RESPONSE" | jq '.data.tickets[0]'

echo ""
echo "4. Getting ticket details..."
GET_TICKET_RESPONSE=$(curl -s -X GET "$BASE_URL/tickets/$TICKET_ID" \
  -H "Authorization: Bearer $USER_ACCESS_TOKEN")

echo "$GET_TICKET_RESPONSE" | jq '.data'

echo ""
echo "5. Login as admin..."
ADMIN_LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "account": "admin@163.com",
    "password": "123456789"
  }')
echo "$ADMIN_LOGIN_RESPONSE" | jq '.'
ADMIN_ACCESS_TOKEN=$(echo "$ADMIN_LOGIN_RESPONSE" | jq -r '.data.accessToken')

echo ""
echo "6. Listing assignable agents..."
LIST_AGENTS_RESPONSE=$(curl -s -X GET "$BASE_URL/admin/agents" \
  -H "Authorization: Bearer $ADMIN_ACCESS_TOKEN")

echo "$LIST_AGENTS_RESPONSE" | jq '.'
AGENT_ID=$(echo "$LIST_AGENTS_RESPONSE" | jq -r '.data[0].id')

echo ""
echo "7. Assigning ticket to agent..."
ASSIGN_RESPONSE=$(curl -s -X PATCH "$BASE_URL/admin/tickets/$TICKET_ID/assign" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_ACCESS_TOKEN" \
  -d "{
    \"agentId\": \"$AGENT_ID\"
  }")

echo "$ASSIGN_RESPONSE" | jq '.'

echo ""
echo "8. Admin replying to ticket (public)..."
ADMIN_REPLY_RESPONSE=$(curl -s -X POST "$BASE_URL/admin/tickets/$TICKET_ID/messages" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_ACCESS_TOKEN" \
  -d '{
    "body": "This is a public reply from admin",
    "isInternal": false
  }')

echo "$ADMIN_REPLY_RESPONSE" | jq '.'

echo ""
echo "9. Admin replying to ticket (internal)..."
INTERNAL_REPLY_RESPONSE=$(curl -s -X POST "$BASE_URL/admin/tickets/$TICKET_ID/messages" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_ACCESS_TOKEN" \
  -d '{
    "body": "This is an internal note",
    "isInternal": true
  }')

echo "$INTERNAL_REPLY_RESPONSE" | jq '.'

echo ""
echo "10. User replying to ticket..."
USER_REPLY_RESPONSE=$(curl -s -X POST "$BASE_URL/tickets/$TICKET_ID/messages" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $USER_ACCESS_TOKEN" \
  -d '{
    "body": "This is a reply from user"
  }')

echo "$USER_REPLY_RESPONSE" | jq '.'

echo ""
echo "11. Admin updating ticket status to IN_PROGRESS..."
UPDATE_STATUS_RESPONSE=$(curl -s -X PATCH "$BASE_URL/admin/tickets/$TICKET_ID/status" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_ACCESS_TOKEN" \
  -d '{
    "status": "IN_PROGRESS"
  }')

echo "$UPDATE_STATUS_RESPONSE" | jq '.'

echo ""
echo "12. Testing invalid status transition (IN_PROGRESS -> OPEN)..."
INVALID_STATUS_RESPONSE=$(curl -s -X PATCH "$BASE_URL/admin/tickets/$TICKET_ID/status" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_ACCESS_TOKEN" \
  -d '{
    "status": "OPEN"
  }')

echo "$INVALID_STATUS_RESPONSE" | jq '.'

echo ""
echo "13. User closing ticket..."
CLOSE_RESPONSE=$(curl -s -X PATCH "$BASE_URL/tickets/$TICKET_ID/close" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $USER_ACCESS_TOKEN" \
  -d '{
    "reason": "Issue resolved"
  }')

echo "$CLOSE_RESPONSE" | jq '.'

echo ""
echo "14. Trying to reply to closed ticket (should fail)..."
REPLY_CLOSED_RESPONSE=$(curl -s -X POST "$BASE_URL/tickets/$TICKET_ID/messages" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $USER_ACCESS_TOKEN" \
  -d '{
    "body": "Trying to reply to closed ticket"
  }')

echo "$REPLY_CLOSED_RESPONSE" | jq '.'

echo ""
echo "15. Trying to assign closed ticket (should fail)..."
ASSIGN_CLOSED_RESPONSE=$(curl -s -X PATCH "$BASE_URL/admin/tickets/$TICKET_ID/assign" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_ACCESS_TOKEN" \
  -d "{
    \"agentId\": \"$AGENT_ID\"
  }")

echo "$ASSIGN_CLOSED_RESPONSE" | jq '.'

echo ""
echo "========================================="
echo "Validation Complete!"
echo "========================================="
