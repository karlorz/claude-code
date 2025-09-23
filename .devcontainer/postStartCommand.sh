# mcp for user scope
claude mcp add -s user --transport http context7 https://mcp.context7.com/mcp
claude mcp add -s user -t sse deepwiki https://mcp.deepwiki.com/sse
claude mcp add -s user --transport http playwright http://192.168.99.11:8931/mcp
echo "MCP servers added successfully"
