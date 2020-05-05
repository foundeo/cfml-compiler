component {
	
	variables.serviceURL = "http://127.0.0.1:50505/__cfml-compiler/compiler.cfc";

	public boolean function serviceUp() {
		return callService(method="serviceUP") == "UP";
	}

	public struct function compiler(string source, string dest, string accessKey="", string extensionFilter="*.cfm|*.cfc" ) {
		var params = [
			{name:"accessKey", value:arguments.accessKey, type:"formfield"},
			{name:"source", value:arguments.source, type:"formfield"},
			{name:"dest", value:arguments.dest, type:"formfield"},
			{name:"extensionFilter", value:arguments.extensionFilter, type:"formfield"}
		];
		return callService(method="compiler", params=params);
	}

	private function callService(string method, array params=[]) {
		var response = "";
		cfhttp(url=variables.serviceURL&"?returnformat=json&method=" & arguments.method, method="POST", result="response") {
			for (local.p in arguments.params) {
				cfhttpparam(name=local.p.name, value=local.p.value, type="formfield");
			}
		}
		if (response.statusCode == "200 OK") {
			return deserializeJSON(response.fileContent);	
		} else {
			throw(message="Response had status: #response.statusCode#", detail=response.fileContent);
		}
		
	}
}