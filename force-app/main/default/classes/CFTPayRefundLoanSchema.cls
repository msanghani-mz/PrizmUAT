public class CFTPayRefundLoanSchema {
    
    public class Request{
        
        public string externalId {get; set;}
        public decimal amount {get; set;}
        public Enrollment enrollment {get; set;}
        public string comment {get; set;}
        public date scheduleDate {get; set;}
        public List<string> tags {get; set;}
        public Loan loan {get; set;}
        public Service service {get; set;}
        public LinkedSchedule linkedSchedule {get; set;}
        public Metadata metadata {get; set;}
    }
    
    public class Enrollment {
        public id loanId {get; set;}
        public string externalId {get; set;}
    }
    
    public class Loan {
        public id loanId {get; set;}
        public string externalId {get; set;}
    }
    
    public class Service {
        public id loanId {get; set;}
        public string externalId {get; set;}
    }
    
    public class LinkedSchedule {
        public string loanId {get; set;}
        public string externalId {get; set;}
    }
    
    public class Metadata {
        public string requester {get; set;}
    }
}