/**
 * @File Name          : BoxFolderCreationQueueable.cls
 * @Description        : 
 * @Author             : financial Spectra
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 8/24/2019, 12:13:28 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    8/24/2019, 12:12:55 AM   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class BoxFolderCreationQueueable implements Queueable,Database.AllowsCallouts {
    
    private Set<Id> mRecordIds;
    
    public BoxFolderCreationQueueable(Set<Id> pRecordIds) {
        this.mRecordIds = pRecordIds;
    }
    public void execute(QueueableContext context) {
        CreateBoxFolderHandler.createFolderSync(mRecordIds);
    }
    
}