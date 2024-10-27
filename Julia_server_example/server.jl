using HTTP
using Sockets

# Define a router for handling routes
const ROUTER = HTTP.Router()

# Define the function to handle adding spaces
function add_spaces(req::HTTP.Request)
    headers = [
        "Access-Control-Allow-Origin" => "*",
        "Access-Control-Allow-Methods" => "POST, OPTIONS"
    ]

    # Handle CORS preflight requests
    if HTTP.method(req) == "OPTIONS"
        return HTTP.Response(200, headers)
    end

    try
        # Get the body as a string
        body = String(req.body)
        # Insert spaces between each character
        spaced_string = join(collect(body), " ")
        HTTP.Response(200, headers, spaced_string)
    catch e
        HTTP.Response(400, headers, "Invalid input: " * string(e))
    end
end

# Register the route for POST requests to "/api/add_spaces"
HTTP.register!(ROUTER, "POST", "/api/add_spaces", add_spaces)

# Start the server on localhost at port 8080
server = HTTP.serve(ROUTER, Sockets.localhost, 8080)

# Test usage
resp = HTTP.post("http://localhost:8080/api/add_spaces"; body="hello")
result = String(resp.body)
@assert result == "h e l l o"

# Close the server after running the tests
close(server)
@assert istaskdone(server.task)
