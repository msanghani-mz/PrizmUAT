public class DocusignFormDataJSON2Apex {

    public class FormData {
        public String name;
        public String value;
        public String originalValue;
    }

    public List<FormData> formData;
    public String envelopeId;
    public String status;
    public String sentDateTime;
    public List<RecipientFormData> recipientFormData;

    public class RecipientFormData {
        public List<FormData> formData;
        public String recipientId;
        public String name;
        public String email;
        public String signedTime;
        public String deliveredTime;
    }

    
    public static DocusignFormDataJSON2Apex parse(String json) {
        return (DocusignFormDataJSON2Apex) System.JSON.deserialize(json, DocusignFormDataJSON2Apex.class);
    }
}