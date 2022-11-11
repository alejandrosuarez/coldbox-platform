/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Base class for all things Box
 * The Majority of contributions comes from its delegations
 *
 * @author Luis Majano <lmajano@ortussolutions.com>
 */
component
	serializable="false"
	accessors   ="true"
	delegates   ="Async@coreDelegates,Interceptor@cbDelegates,Settings@cbDelegates,Flow@coreDelegates,Env@coreDelegates,JsonUtil@coreDelegates,Population@cbDelegates,Rendering@cbDelegates"
{

	/****************************************************************
	 * DI *
	 ****************************************************************/

	property
		name    ="cachebox"
		inject  ="cachebox"
		delegate="getCache";
	property name="controller" inject="coldbox";
	property name="flash"      inject="coldbox:flash";
	property name="logBox"     inject="logbox";
	property name="log"        inject="logbox:logger:{this}";
	property
		name    ="wirebox"
		inject  ="wirebox"
		delegate="getInstance";

	/**
	 * Constructor
	 */
	function init(){
		return this;
	}

	/****************************************************************
	 * Deprecated/Removed Methods *
	 ****************************************************************/

	function renderview() cbMethod{
		throw(
			type    = "DeprecatedMethod",
			message = "This method has been deprecated, please use 'view()` instead"
		);
	}
	function renderLayout() cbMethod{
		throw(
			type    = "DeprecatedMethod",
			message = "This method has been deprecated, please use 'layout()` instead"
		);
	}
	function renderExternalView() cbMethod{
		throw(
			type    = "DeprecatedMethod",
			message = "This method has been deprecated, please use 'externalView()` instead"
		);
	}
	function announceInterception() cbMethod{
		throw(
			type    = "DeprecatedMethod",
			message = "This method has been deprecated, please use 'announce()` instead"
		);
	}

	/**
	 * Retrieve the request context object
	 *
	 * @return coldbox.system.web.context.RequestContext
	 */
	function getRequestContext() cbMethod{
		return variables.controller.getRequestService().getContext();
	}

	/**
	 * Get the RC or PRC collection reference
	 *
	 * @private The boolean bit that says give me the RC by default or true for the private collection (PRC)
	 *
	 * @return The requeted collection
	 */
	struct function getRequestCollection( boolean private = false ) cbMethod{
		return getRequestContext().getCollection( private = arguments.private );
	}

	/**
	 * Get an interceptor reference
	 *
	 * @interceptorName The name of the interceptor to retrieve
	 *
	 * @return Interceptor
	 */
	function getInterceptor( required interceptorName ) cbMethod{
		return variables.controller.getInterceptorService().getInterceptor( argumentCollection = arguments );
	}

	/**
	 * Relocate user browser requests to other events, URLs, or URIs.
	 *
	 * @event             The name of the event to run, if not passed, then it will use the default event found in your configuration file
	 * @URL               The full URL you would like to relocate to instead of an event: ex: URL='http://www.google.com'
	 * @URI               The relative URI you would like to relocate to instead of an event: ex: URI='/mypath/awesome/here'
	 * @queryString       The query string or struct to append, if needed. If in SES mode it will be translated to convention name value pairs
	 * @persist           What request collection keys to persist in flash ram
	 * @persistStruct     A structure key-value pairs to persist in flash ram
	 * @addToken          Wether to add the tokens or not. Default is false
	 * @ssl               Whether to relocate in SSL or not
	 * @baseURL           Use this baseURL instead of the index.cfm that is used by default. You can use this for ssl or any full base url you would like to use. Ex: https://mysite.com/index.cfm
	 * @postProcessExempt Do not fire the postProcess interceptors
	 * @statusCode        The status code to use in the relocation
	 */
	void function relocate(
		event,
		URL,
		URI,
		queryString,
		persist,
		struct persistStruct,
		boolean addToken,
		boolean ssl,
		baseURL,
		boolean postProcessExempt,
		numeric statusCode
	) cbMethod{
		variables.controller.relocate( argumentCollection = arguments );
	}

	/**
	 * Redirect back to the previous URL via the referrer header, else use the fallback
	 *
	 * @fallback The fallback event or uri if the referrer is empty, defaults to `/`
	 */
	function back( fallback = "/" ) cbMethod{
		var event = getRequestContext();
		relocate( URL = event.getHTTPHeader( "referer", event.buildLink( arguments.fallback ) ) );
	}

	/**
	 * Executes internal named routes with or without parameters. If the named route is not found or the route has no event to execute then this method will throw an `InvalidArgumentException`.
	 * If you need a route from a module then append the module address: `@moduleName` or prefix it like in run event calls `moduleName:routeName` in order to find the right route.
	 * The route params will be passed to events as action arguments much how eventArguments work.
	 *
	 * @name                   The name of the route
	 * @params                 The parameters of the route to replace
	 * @cache                  Cached the output of the runnable execution, defaults to false. A unique key will be created according to event string + arguments.
	 * @cacheTimeout           The time in minutes to cache the results
	 * @cacheLastAccessTimeout The time in minutes the results will be removed from cache if idle or requested
	 * @cacheSuffix            The suffix to add into the cache entry for this event rendering
	 * @cacheProvider          The provider to cache this event rendering in, defaults to 'template'
	 * @prePostExempt          If true, pre/post handlers will not be fired. Defaults to false
	 *
	 * @return null or anything produced from the route
	 *
	 * @throws InvalidArgumentException
	 */
	any function runRoute(
		required name,
		struct params          = {},
		boolean cache          = false,
		cacheTimeout           = "",
		cacheLastAccessTimeout = "",
		cacheSuffix            = "",
		cacheProvider          = "template",
		boolean prePostExempt  = false
	) cbMethod{
		return variables.controller.runRoute( argumentCollection = arguments );
	}

	/**
	 * Executes events with full life-cycle methods and returns the event results if any were returned.
	 *
	 * @event                  The event string to execute, if nothing is passed we will execute the application's default event.
	 * @prePostExempt          If true, pre/post handlers will not be fired. Defaults to false
	 * @private                Execute a private event if set, else defaults to public events
	 * @defaultEvent           The flag that let's this service now if it is the default event running or not. USED BY THE FRAMEWORK ONLY
	 * @eventArguments         A collection of arguments to passthrough to the calling event handler method
	 * @cache                  Cached the output of the runnable execution, defaults to false. A unique key will be created according to event string + arguments.
	 * @cacheTimeout           The time in minutes to cache the results
	 * @cacheLastAccessTimeout The time in minutes the results will be removed from cache if idle or requested
	 * @cacheSuffix            The suffix to add into the cache entry for this event rendering
	 * @cacheProvider          The provider to cache this event rendering in, defaults to 'template'
	 *
	 * @return null or anything produced from the event
	 */
	function runEvent(
		event                  = "",
		boolean prePostExempt  = false,
		boolean private        = false,
		boolean defaultEvent   = false,
		struct eventArguments  = {},
		boolean cache          = false,
		cacheTimeout           = "",
		cacheLastAccessTimeout = "",
		cacheSuffix            = "",
		cacheProvider          = "template"
	) cbMethod{
		return variables.controller.runEvent( argumentCollection = arguments );
	}

	/**
	 * Persist variables into the Flash RAM
	 *
	 * @persist       A list of request collection keys to persist
	 * @persistStruct A struct of key-value pairs to persist
	 *
	 * @return FrameworkSuperType
	 */
	function persistVariables( persist = "", struct persistStruct = {} ) cbMethod{
		variables.controller.persistVariables( argumentCollection = arguments );
		return this;
	}

	/****************************************** UTILITY METHODS ******************************************/

	/**
	 * Resolve a file to be either relative or absolute in your application
	 *
	 * @pathToCheck The file path to check
	 */
	string function locateFilePath( required pathToCheck ) cbMethod{
		return variables.controller.locateFilePath( argumentCollection = arguments );
	}

	/**
	 * Resolve a directory to be either relative or absolute in your application
	 *
	 * @pathToCheck The file path to check
	 */
	string function locateDirectoryPath( required pathToCheck ) cbMethod{
		return variables.controller.locateDirectoryPath( argumentCollection = arguments );
	}

	/**
	 * Add a js/css asset(s) to the html head section. You can also pass in a list of assets. This method
	 * keeps track of the loaded assets so they are only loaded once
	 *
	 * @asset The asset(s) to load, only js or css files. This can also be a comma delimited list.
	 */
	string function addAsset( required asset ) cbMethod{
		return getInstance( "@HTMLHelper" ).addAsset( argumentCollection = arguments );
	}

	/**
	 * Injects a UDF Library (*.cfc or *.cfm) into the target object.  It does not however, put the mixins on any of the cfc scopes. Therefore they can only be called internally
	 *
	 * @udflibrary The UDF library to inject
	 *
	 * @return FrameworkSuperType
	 *
	 * @throws UDFLibraryNotFoundException - When the requested library cannot be found
	 */
	any function includeUDF( required udflibrary ) cbMethod{
		// Init the mixin location and caches reference
		var defaultCache     = getCache( "default" );
		var mixinLocationKey = hash( variables.controller.getAppHash() & arguments.udfLibrary );

		var targetLocation = defaultCache.getOrSet(
			// Key
			"includeUDFLocation-#mixinLocationKey#",
			// Producer
			function(){
				var appMapping      = variables.controller.getSetting( "AppMapping" );
				var UDFFullPath     = expandPath( udflibrary );
				var UDFRelativePath = expandPath( "/" & appMapping & "/" & udflibrary );

				// Relative Checks First
				if ( fileExists( UDFRelativePath ) ) {
					targetLocation = "/" & appMapping & "/" & udflibrary;
				}
				// checks if no .cfc or .cfm where sent
				else if ( fileExists( UDFRelativePath & ".cfc" ) ) {
					targetLocation = "/" & appMapping & "/" & udflibrary & ".cfc";
				} else if ( fileExists( UDFRelativePath & ".cfm" ) ) {
					targetLocation = "/" & appMapping & "/" & udflibrary & ".cfm";
				} else if ( fileExists( UDFFullPath ) ) {
					targetLocation = "#udflibrary#";
				} else if ( fileExists( UDFFullPath & ".cfc" ) ) {
					targetLocation = "#udflibrary#.cfc";
				} else if ( fileExists( UDFFullPath & ".cfm" ) ) {
					targetLocation = "#udflibrary#.cfm";
				} else {
					throw(
						message = "Error loading UDF library: #udflibrary#",
						detail  = "The UDF library was not found.  Please make sure you verify the file location.",
						type    = "UDFLibraryNotFoundException"
					);
				}
				return targetLocation;
			},
			// Timeout: 1 week
			10080
		);

		// Include the UDF
		include targetLocation;

		return this;
	}

	/**
	 * Load the global application helper libraries defined in the applicationHelper Setting of your application.
	 * This is called by the framework ONLY! Use at your own risk
	 *
	 * @force Used when called by a known virtual inheritance family tree.
	 *
	 * @return FrameworkSuperType
	 */
	any function loadApplicationHelpers( boolean force = false ) cbMethod{
		if ( structKeyExists( this, "$super" ) && !arguments.force ) {
			return this;
		}

		// Inject global helpers
		var helpers = variables.controller.getSetting( "applicationHelper" );

		for ( var thisHelper in helpers ) {
			includeUDF( thisHelper );
		}

		return this;
	}

}
