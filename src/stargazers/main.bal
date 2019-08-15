public function main() {
    json[] getResult = get("ballerina-platform", "ballerina-lang");
    io:println(string `Found ${getResult.length()} stargazers!`);
    var wbc = io:openWritableFile("./stargazers.json");
    if (wbc is io:WritableByteChannel) {
        io:WritableCharacterChannel wch = new(wbc, "UTF8");
        var result = wch.writeJson(getResult);
    }
}