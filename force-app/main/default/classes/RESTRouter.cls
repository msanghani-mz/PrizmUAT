/*
 * Class Name   - RESTRouter
 * Description  - REST Versara Request Router. This class will route all 
 *                the requests to /versara... to the appropriate handler
 * Developer(s) - Financial Spectra DEV
 */
@RestResource(urlMapping='/versara/*')
global class RESTRouter {
    
    private static final String BASE_PATH = '/versara';
    
    @HttpGet
    global static void doGet(){
        getServiceHandler().doGet();
    }
    
    @HttpPut
    global static void doPut(){
        getServiceHandler().doPut();
    }
    
    @HttpPost
    global static void doPost(){
        getServiceHandler().doPost();
    }

    @HttpDelete
    global static void doDelete(){
        getServiceHandler().doDelete();
    }

    private static fsCore.RESTServiceHandler getServiceHandler(){
        String resourceURI;
        if (String.IsNotBlank(RestContext.request.requestURI)){
            resourceURI = RestContext.request.requestURI.substringAfter(BASE_PATH); //gets the URI after /config
        }
        System.debug(loggingLevel.ERROR, '-- resourceURI : ' + resourceURI);
       
        if (String.IsBlank(resourceURI)){
            throw new RESTRouterException('Invalid end point.');
        }
        
        fsCore.RESTServiceHandler serviceHdlr = fsCore.RESTServiceHandlerFactory.getServiceHandler(resourceURI);
        return serviceHdlr;
    }

    global class RESTRouterException extends Exception{}
    
}