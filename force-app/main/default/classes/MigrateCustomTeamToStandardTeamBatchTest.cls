@isTest
public without sharing class MigrateCustomTeamToStandardTeamBatchTest {
    
    
    static Map<String, String> mapOfAccessLevel = new Map<String, String>{'Read/Write' => 'Edit', 'Read Only' => 'Read', 
            'Private' => 'None'};
    /*
    static Map<String, String> mapOfAccessLevelForOpp = new Map<String, String>{'Read/Write' => 'Edit', 'Read Only' => 'Read', 
            'Private' => 'Edit'};
    */

    @TestSetup
    static void makeData() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 

        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;

        User ownerUsr = new User(Alias = 'standt', Email='owneruser@testorg.com', 
                    EmailEncodingKey='UTF-8', LastName='Owner', LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', ProfileId = p.Id, 
                    TimeZoneSidKey='America/Los_Angeles', UserName='owneruser@testorg.com', 
                    UserRoleId = r.Id);
        
        insert ownerUsr;
        
        User teamMemberUsr = new User(Alias = 'standt', Email='teammemberuser@testorg.com', 
                    EmailEncodingKey='UTF-8', LastName='Team Member', LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', ProfileId = p.Id, 
                    TimeZoneSidKey='America/Los_Angeles', UserName='teammemberuser@testorg.com', 
                    UserRoleId = r.Id);
        
		insert teamMemberUsr;

        System.runAs(ownerUsr) {

            RecordType accRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Competitor'];

            Map<String, Account> newAccs = new Map<String, Account>();

            for(String key : mapOfAccessLevel.keySet()) {
                newAccs.put(key, new Account(
                    Name = 'Test Account ',
                    RecordTypeId = accRecordType.Id,
                    CurrencyIsoCode = 'USD',
                    Type = 'Competitor',
                    Region_R1__c = 'UNITED STATES'
                ));
            }
			
            /*
            newAccs.put('Owner', new Account(
                Name = 'Owner Test Account ',
                RecordTypeId = accRecordType.Id,
                CurrencyIsoCode = 'USD',
                Type = 'Competitor',
                Region_R1__c = 'UNITED STATES'
            ));
            */
            
            insert newAccs.values();

            AccountName__c acctName = new AccountName__c();
            acctName.Name = 'FastChem Corp';
            acctName.OlinAccountValue__c = newAccs.get('Read/Write').id;
            insert acctName;

            List<Team__c> newTeams = new List<Team__c>();
            
            Integer counter = 0;

            for(String accessLevel : mapOfAccessLevel.keySet()) {

                newTeams.add(new Team__c(
                    Account__c = newAccs.get(accessLevel).Id,
                    Account_Access__c = accessLevel,
                    Case_Access__c = accessLevel,
                    Opportunity_Access__c = accessLevel,
                    Team_Member__c = teamMemberUsr.Id,
                    Team_Role__c = 'Account Manager'
                ));

            }
			
            /*
            newTeams.add(new Team__c(
                Account__c = newAccs.get('Owner').Id,
                Account_Owner__c = true,
                Account_Access__c = 'Read/Write',
                Case_Access__c = 'Private',
                Opportunity_Access__c = 'Private',
                Team_Member__c = ownerUsr.Id,
                Team_Role__c = 'Account Manager'
            ));
			*/
            
            insert newTeams;

        }

    }

    @isTest
    private static void testBatchClass() {

        Test.startTest();
            Database.executeBatch(new MigrateCustomTeamToStandardTeamBatch());
        Test.stopTest();

        Map<Id, Account> accs = new Map<Id, Account>([SELECT Id, 
            (SELECT Account__c, Account_Owner__c, Account_Access__c, Case_Access__c, 
                Opportunity_Access__c, Team_Member__c, Team_Role__c FROM Teams__r WHERE Account_Owner__c = False), 
            (SELECT AccountId, Account.OwnerId, UserId, AccountAccessLevel, CaseAccessLevel, 
                OpportunityAccessLevel, TeamMemberRole FROM AccountTeamMembers) FROM Account]);

        System.debug(accs.keySet());
        for(Account acc : accs.values()) {

            List<Team__c> newTeams = acc.Teams__r;
            List<AccountTeamMember> newAccTeamMembers = acc.AccountTeamMembers;
			List<AccountTeamMember> accTeamMembersNotAccOwner = new List<AccountTeamMember>();
            
            for(AccountTeamMember accTeam : newAccTeamMembers) {
                if(accTeam.Account.OwnerId != accTeam.UserId) 
                    accTeamMembersNotAccOwner.add(accTeam);
            }
            
            for(Integer i = 0; i < newTeams.size(); i++) {
                
                Team__c newTeam = newTeams[i];
                AccountTeamMember newAccTeamMember = accTeamMembersNotAccOwner[i];
                
                System.debug(acc.Id + ' - ' + newTeam);
                System.debug(acc.Id + ' - ' + newAccTeamMember);

                String accAccess = (newTeam.Account_Owner__c)? 'Edit' : mapOfAccessLevel.get(newTeam.Account_Access__c);
                String caseAccess = (newTeam.Account_Owner__c)? 'Edit' : mapOfAccessLevel.get(newTeam.Case_Access__c);
                String oppAccess = (newTeam.Account_Owner__c)? 'Edit' : mapOfAccessLevel.get(newTeam.Opportunity_Access__c);
				
                if(newTeam.Account_Access__c == 'Private') 
                    accAccess = 'Read';
                
                if(newTeam.Opportunity_Access__c == 'Private')
                    oppAccess = 'Edit';

                System.debug(accAccess + ' - ' + caseAccess + ' - ' + oppAccess);
                
                System.assertEquals(newTeam.Account__c, newAccTeamMember.AccountId);
                System.assertEquals(accAccess, newAccTeamMember.AccountAccessLevel);
                System.assertEquals(caseAccess, newAccTeamMember.CaseAccessLevel);
                System.assertEquals(oppAccess, newAccTeamMember.OpportunityAccessLevel);
                System.assertEquals(newTeam.Team_Member__c, newAccTeamMember.UserId);
                System.assertEquals(newTeam.Team_Role__c, newAccTeamMember.TeamMemberRole);

            }
        }

        List<AccountShare> accShares = [SELECT Account.Name, AccountAccessLevel, CaseAccessLevel, OpportunityAccessLevel, 
                RowCause FROM AccountShare WHERE AccountId IN :accs.keySet() AND RowCause = 'Team' ORDER BY Id ];

        System.debug(accShares);

    }

}