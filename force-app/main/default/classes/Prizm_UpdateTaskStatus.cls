@RestResource(urlMapping='/updateTaskStatus/*')
global class Prizm_UpdateTaskStatus{

    @HttpPost
    global static String updateTaskStatus() {
        
        String jsonStr;
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        if(!Test.isRunningTest()){
             jsonStr = RestContext.request.requestBody.toString();
        } else {
            List<TaskStatusWrapper> TaskWrapperList = new List<TaskStatusWrapper>();
            TaskStatusWrapper tW = new TaskStatusWrapper();
            tW.TaskId = [Select Id from Task limit 1].Id;
            tW.Status = 'Completed';
            tW.DueDate= String.valueOf(Date.Today());
            tW.DueDateTime=String.valueOf(System.now());
            tW.Description='Test Description';
            
            TaskWrapperList.add(tW);
            jsonStr = JSON.serialize(TaskWrapperList);
        }
        List<TaskStatusWrapper> TaskWrapperList = (List<TaskStatusWrapper>)JSON.deserialize(jsonStr,List<TaskStatusWrapper>.class);
        
        List<Task> TaskList = new List<Task>();
        
        for(TaskStatusWrapper TaskWrap : TaskWrapperList){
            Task t = new Task();
            t.Import_Id__c = TaskWrap.TaskId;
            t.Status = TaskWrap.Status;
            t.Description = TaskWrap.Description;
           /* String dt = TaskWrap.DueDate;
            string[] RFQdate = String.valueOf(dt.trim()).split('/'); 
            date mydate = date.valueOf(RFQdate[2] + '-' + RFQdate[0] + '-' + RFQdate[1]);
            t.ActivityDate = Date.valueOf(mydate);*/
            t.ActivityDate = Date.valueOf(TaskWrap.DueDate);
            
            if(TaskWrap.DueDateTime!='')
               t.Due_Date_Time__c = DateTime.valueOf(TaskWrap.DueDateTime);
            else{
                Date d=System.today()+1;
                t.Due_Date_Time__c = DateTime.newInstance(d.Year(), d.month(), d.day(), 9, 0, 0);
                }
                
            
            TaskList.add(t);
            
        }
        Schema.SObjectField importIdTaskField = Task.Import_Id__c;
        Database.Upsert(TaskList,importIdTaskField,false);
        return 'true';
        
    }
    
    public class TaskStatusWrapper{
        public string TaskId;
        public String Status;
        public String Description;
        public String DueDate;
        public String DueDateTime;
        
        public TaskStatusWrapper(){
            TaskId = '';
            Status = '';
            Description = '';
            DueDate='';
            DueDateTime='';
        }
    }

}