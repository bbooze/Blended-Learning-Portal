<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>BLP Alert For Review of Course Detail</fullName>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <template>BLP_Email_Templates/BLP_Reminder_for_Review_Date</template>
    </alerts>
    <alerts>
        <fullName>BLP Training In Draft For 6 Months Alert</fullName>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <template>BLP_Email_Templates/BLP_Training_In_Draft_For_6_Months</template>
    </alerts>
    <alerts>
        <fullName>Course Review Remainder 0 Days Before Review Date</fullName>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <template>BLP_Email_Templates/BLP_Reminder_for_Review_Date</template>
    </alerts>
    <alerts>
        <fullName>Review Course Detail before Reminder Date</fullName>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <template>BLP_Email_Templates/BLP_Reminder_for_Review_Date</template>
    </alerts>
    <fieldUpdates>
        <fullName>BLP Update Tech Support</fullName>
        <field>BLP_Tech_Support__c</field>
        <formula>Owner:User.FirstName&amp;&apos; &apos;&amp;Owner:User.LastName</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BLP Update Tech Support Email</fullName>
        <field>BLP_Tech_Support_Email__c</field>
        <formula>Owner:User.Email</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate Draft Status Updated On</fullName>
        <description>Populate value in &quot;Draft Status Updated On&quot;</description>
        <field>BLP_Draft_Status_Updated_On__c</field>
        <formula>TODAY()</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>BLP Reminder For Review Date</fullName>
        <actions>
            <name>Please Review the Course Detail</name>
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
    </rules>
    <rules>
        <fullName>BLP_Update_Tech_Support</fullName>
        <actions>
            <name>BLP Update Tech Support</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>BLP Update Tech Support Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISBLANK(BLP_Tech_Support__c)
&amp;&amp; (ISNEW()
      || ISCHANGED(BLP_Tech_Support__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>test</fullName>
        <active>false</active>
        <criteriaItems>
            <field>BLP_Course__c.BLP_Availability__c</field>
            <operation>equals</operation>
            <value>Open</value>
        </criteriaItems>
        <description>to delete</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Please Review the Course Detail</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>BLP_Course__c.BLP_Review_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
    </tasks>
    <tasks>
        <fullName>Please Review the Course Detail</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>BLP_Course__c.BLP_Review_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
    </tasks>
    <tasks>
        <fullName>Review Course Detail</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>BLP_Course__c.BLP_Review_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
    </tasks>
</Workflow>
