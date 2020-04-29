public class JiraResponse {

    public String self;
    public String id;
    public String name;
    public Boolean archived;
    public Boolean released;
    public String releaseDate;
    public Boolean overdue;
    public String userReleaseDate;
    public Integer projectId;

    
    public static JiraResponse parse(String json) {
        return (JiraResponse) System.JSON.deserialize(json, JiraResponse.class);
    }
}