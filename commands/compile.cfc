/**
 * compiles CFML code
 * .
 * Examples
 * {code:bash}
 * compile /path/to/folder
 * {code}
 **/
component extends="commandbox.system.BaseCommand" excludeFromHelp=false {

	
	property inject="compiler@cfml-compiler" name="compiler";

	/**
	* @source.hint A file or directory to compile
	* @dest.hint The destination of the compiled file(s)
	* @overwrite.hint Allow overwrite without prompting
	* @cfengine.hint The cfml engine version to compile for
	**/
	function run(source="./", string dest="", boolean overwrite="false", string cfengine="")  {
		

		arguments.source = fileSystemUtil.resolvePath(arguments.source);
		if (!directoryExists(arguments.source) && !fileExists(arguments.source))  {
			print.redLine("The source path was not a directory or file.");
			setExitCode(1);
			return;
		}

		if (arguments.dest == "") {
			arguments.dest = arguments.source;
		} else {
			arguments.dest = fileSystemUtil.resolvePath(arguments.dest);
		}

		if (!arguments.overwrite) {
			
			if (arguments.dest == arguments.source) {
				local.allowOverwrite = ask(message="The source code will be overwritten, type: OK if you want to continue: ");
				if (local.allowOverwrite != "OK") {
					print.redLine("10-4, exiting");
					return;
				}
			}
		}
		
		
		

		try {
			local.accessKey = reReplace(generateSecretKey("AES"), "[^a-zA-Z0-9]", randRange(0,9), "ALL");
			local.compilerObj = compiler;
			local.up = false;
			if (len(arguments.cfengine) || 1==1) {
				if (fileExists(arguments.source & "/__cfml-compiler/")) {
					throw(message="Compiler folder already exists in: #arguments.source#");
				}
				directoryCopy(getCompilerRoot(), arguments.source & "/__cfml-compiler/")
				local.serverArgs = {
					name="cfml-compiler-server",
					port=50505,
					host="127.0.0.1",
					saveSettings=false,
					JVMArgs="-Dcfmlcompilerkey=" & local.accessKey,
					cfengine=arguments.cfengine,
					openbrowser=false,
					directory=arguments.source
				};
				command( "server start" )
    			.params( argumentCollection=local.serverArgs )
    			.run();
    			
    			for (local.i =0;i<20;i++) {
    				sleep(1000);
    				try {
    					local.compilerObj = createObject("webservice", "http://127.0.0.1:50505/__cfml-compiler/compiler.cfc?wsdl");
    					if (local.compilerObj.serviceUp() == "UP") {
    						local.up = true;
    						break;
    					}
    					print.yellowLine("Waiting for server to start: #i#/20");
    				} catch (any err) {
    					//try again
    				}
    			}
    			
    		} else {
    			createObject("java", "java.lang.System").setProperty("cfmlcompilerkey", local.accessKey);
    			local.up = true;
    		}
    		if (!local.up) {
    				print.redLine("Unable to start compiler server after 20 seconds.");
				setExitCode(1);
			} else {
				print.greenLine("Starting compilation of: #arguments.source#");
				print.greenLine("Destination: #arguments.dest#");
    			local.result = local.compilerObj.compiler(source=arguments.source, dest=arguments.dest, accessKey=local.accessKey);
    			if (local.result == "done") {
    				print.greenLine("Finished!");
    			} else {
    				print.yellowLine("Unexpected Result: #local.result#");
    			}

			}
    		


		} catch (any err) {
			if (err.message contains "exit code (1)") {
				setExitCode( 1 );
			} else {
				rethrow;
			}
			
		} finally {
			
			if (len(arguments.cfengine) || 1 == 1) {
				command( "server stop" )
    				.params( name="cfml-compiler-server" )
    				.run();	
    			sleep(100);
    			command( "server forget" )
    				.params( name="cfml-compiler-server", force=true )
    				.run();	
    			sleep(100);
    			if (directoryExists(arguments.source & "/__cfml-compiler/")) {
					directoryDelete(arguments.source & "/__cfml-compiler/", true);
				}
				if (directoryExists(arguments.dest & "/__cfml-compiler/")) {
					directoryDelete(arguments.dest & "/__cfml-compiler/", true);
				}
			}
			
		}
		
		
	}




	private function getCompilerRoot() {
		var p = getCurrentTemplatePath();
		p = replace(p, "\", "/", "ALL");
		return replace(p, "commands/compile.cfc", "models"); 
	}

	private function getCompilerFilePath() {
		var p = getCurrentTemplatePath();
		p = replace(p, "\", "/", "ALL");
		return replace(p, "commands/compile.cfc", "models/compiler.cfc"); 
	}
	

}