<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>BLP_Alert_For_Review_of_Course_Detail</fullName>
        <description>BLP Alert For Review of Course Detail</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BLP_Email_Templates/BLP_Reminder_for_Review_Date</template>
    </alerts>
    <alerts>
        <fullName>BLP_Course_Review_Remainder_0_Days_Before_Review_Date</fullName>
        <description>BLP Course Review Remainder 0 Days Before Review Date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BLP_Email_Templates/BLP_Reminder_for_Review_Date</template>
    </alerts>
    <alerts>
        <fullName>BLP_Review_Course_Detail_before_Reminder_Date</fullName>
        <description>BLP Review Course Detail before Reminder Date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BLP_Email_Templates/BLP_Reminder_for_Review_Date</template>
    </alerts>
    <alerts>
        <fullName>BLP_Training_In_Draft_For_6_Months_Alert</fullName>
        <description>BLP Training In Draft For 6 Months Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BLP_Email_Templates/BLP_Training_In_Draft_For_6_Months</template>
    </alerts>
    <fieldUpdates>
        <fullName>BLP_Update_Tech_Support</fullName>
        <field>BLP_Tech_Support__c</field>
        <formula>Owner:User.FirstName&amp;&apos; &apos;&amp;Owner:User.LastName</formula>
        <name>BLP Update Tech Support</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BLP_Update_Tech_Support_Email</fullName>
        <field>BLP_Tech_Support_Email__c</field>
        <formula>Owner:User.Email</formula>
        <name>BLP Update Tech Support Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Draft_Status_Updated_On</fullName>
        <description>Populate value in &quot;Draft Status Updated On&quot;</description>
        <field>BLP_Draft_Status_Updated_On__c</field>
        <formula>TODAY()</formula>
        <name>Populate Draft Status Updated On</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>BLP Reminder For Review Date</fullName>
        <actions>
            <name>BLP_Please_Review_the_Course_Detail_before_Review_Date</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>BLP_Course__c.BLP_Send_Review_Date_Notifications__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>BLP_Course__c.BLP_Status__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>BLP_Course_Review_Remainder_0_Days_Before_Review_Date</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>BLP_Course__c.BLP_Review_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>BLP_Alert_For_Review_of_Course_Detail</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>BLP_Course__c.BLP_Review_Reminder_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>BLP_Review_Course_Detail_before_Reminder_Date</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>BLP_Course__c.BLP_Review_Date__c</offsetFromField>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>BLP_Update_Tech_Support</fullName>
        <actions>
            <name>BLP_Update_Tech_Support</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>BLP_Update_Tech_Support_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISBLANK(BLP_Tech_Support__c)
&amp;&amp; (ISNEW()
      || ISCHANGED(BLP_Tech_Support__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>BLP_Please_Review_the_Course_Detail</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>BLP_Course__c.BLP_Review_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Please Review the Course Detail</subject>
    </tasks>
    <tasks>
        <fullName>BLP_Please_Review_the_Course_Detail_before_Review_Date</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>BLP_Course__c.BLP_Review_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Please Review the Course Detail</subject>
    </tasks>
    <tasks>
        <fullName>BLP_Review_Course_Detail</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>BLP_Course__c.BLP_Review_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Review Course Detail</subject>
    </tasks>
</Workflow>
