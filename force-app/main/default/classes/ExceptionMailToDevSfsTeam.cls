public class ExceptionMailToDevSfsTeam  {
    public Exception Cause;
    public Integer LineNumber;
    public String message;
    public String types;
    public String subject;
    /*public ExceptionMailToDevSfsTeam(Exception cause,Integer LineNumber,String msg,String types) 
    {
        this.Cause=cause;
        this.LineNumber=LineNumber;
        this.message=msg +LineNumber;
        this.types=types;
        this.subject='Prizm_Integration Exception: '+types;
    }*/
    public ExceptionMailToDevSfsTeam(Integer LineNumber,String msg,String types) 
    {
        //this.Cause=cause;
        this.LineNumber=LineNumber;
        this.message=msg + LineNumber;
        this.types=types;
        this.subject='Prizm_Integration Custom Exception:'+types;
    }
    
    public void sendEmailToTeam(){
        list<String> mailAdresses=new list<String>();
        list<User> lstUsers=[select id, name, email, isactive, profile.name, userrole.name, usertype from user where id in 
                            (select userorgroupid from groupmember where group.name = 'Developer & SFS Team')];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(User u:lstUsers){
           mailAdresses.add(u.Email); 
        }
        mailAdresses.add('rchauhan@mindzcloud.com'); //##Temporary
       // mailAdresses.add('abhandari@stratfs.com');  //Mandetory
        Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
        //String[] toAddresses = new String[] {'test@gmail.com'};
        mail.setToAddresses(mailAdresses);
        //mail.setReplyTo('pjogi@mindzcloud.com');
        //mail.setSenderDisplayName('Custom Exception:'+Cause);  //
        mail.setSubject(subject + ' : '+UserInfo.getOrganizationName());
        mail.setPlainTextBody(message);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}