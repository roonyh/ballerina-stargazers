import ballerina/http;

http:Client github = new ("https://api.github.com/");
json[] result = [];

public function get(string org, string repo) returns @tainted json[] {
    http:Request request = new;
    request.addHeader("Authorization", "token 23f5e63cb4a6f6f7317ef983340a8792e750e59b");
    (http:Response | error) response = github->get(string `/repos/${org}/${repo}/stargazers`, request);
    if (response is http:Response) {
        var payload = response.getJsonPayload();
        if (payload is json[]) {
            result.push(...payload);
            getNext(<@untainted> response.getHeader("Link"));
        } else {
            return result;
        }
    }

    return result;
}

function getNext(string header) {
    var val = split(header, ", ");

    string nextUriSubstring = "";

    foreach string str in val {
        if (str.indexOf("rel=\"next\"") is int) {
            nextUriSubstring = str;
        }
    }

    if (nextUriSubstring == "") {
        return;
    }

    string nextUri = nextUriSubstring.substring(("<https://api.github.com".length()), nextUriSubstring.indexOf(">")?:0);
    io:println(nextUri);
    http:Request request = new;
    request.addHeader("Authorization", "token 23f5e63cb4a6f6f7317ef983340a8792e750e59b");

    (http:Response | error) response = github->get(nextUri, request);
    if (response is http:Response) {
        var payload = response.getJsonPayload();
        if (payload is json[]) {
            result.push(...payload);
            getNext(<@untainted> response.getHeader("Link"));
        } else {
            return;
        }
    }
}

public function split(string str, string splitter) returns string[] {
    string[] split = [];
    int splitterLength = splitter.length();
    string remaining = str;
    while (true) {
        int? end = remaining.indexOf(splitter);
        if (end is int) {
            string processed = remaining.substring(0, end);
            split.push(processed);
            remaining = remaining.substring(end + splitterLength, remaining.length());
        } else {
            split.push(remaining);
            break;
        }
    }

    return split; 
}
