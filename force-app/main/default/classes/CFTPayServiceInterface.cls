public interface CFTPayServiceInterface {

    /* Method to set the single input for webservice */
    void setInput(Id pInputID);

    /* Method to set the bulk input for webservice */
    void setInput(Set<Id> pInputIDs);

    /* Method to set the Http Request for webservice */
    void setRequest(HttpRequest pRequest);

    /* Method to invoke the CFTPay Webservice */
    void invoke();

    /* Method to get the Http Response of webservice */
    HttpResponse getResponse();

}