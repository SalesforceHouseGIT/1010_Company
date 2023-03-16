public with sharing class LeadTriggerActions {

    public static void assignLeadOwner(List<Lead> newLeads) {
        
        Datetime dayOfTheWeek = Datetime.now();
        String nameOfTheDay = dayOfTheWeek.format('EEEE', 'America/Los_Angeles');
        Integer hourOfTheDay = dayOfTheWeek.hour();
        List<DaysOfTheWeekClass> listOfDays = createDaysOfTheWeekList();
            
        if (hourOfTheDay < 18) {

            String apiNameDay = getApiNameOfDay(nameOfTheDay, listOfDays, false);

            String queryString = 'SELECT MasterLabel ' +
                                 'FROM Agents_Schedule__mdt ' +
                                 'WHERE ' + apiNameDay + ' = true';
            List<Agents_Schedule__mdt> agentsWorkingNow = Database.query(queryString);

            String newOwnerId = getOwnerId(agentsWorkingNow);

            if (String.isNotBlank(newOwnerId)) {
                for (Lead leadItem : newLeads) {
                    leadItem.OwnerId = newOwnerId;
                }
            }

        } else {
            
            String apiNameDay = getApiNameOfDay(nameOfTheDay, listOfDays, true);

            String queryString = 'SELECT MasterLabel ' +
                                 'FROM Agents_Schedule__mdt ' +
                                 'WHERE ' + apiNameDay + ' = true';
            List<Agents_Schedule__mdt> agentsWorkingNow = Database.query(queryString);

            String newOwnerId = getOwnerId(agentsWorkingNow);

            if (String.isNotBlank(newOwnerId)) {
                for (Lead leadItem : newLeads) {
                    leadItem.OwnerId = newOwnerId;
                }
            }

        }

    }
    
    public static void stampDateOfContacted(Map<Id, Lead> leadNewMap, Map<Id, Lead> leadOldMap) {

        for (Lead leadRecord : leadNewMap.values()) {
            if (leadOldMap.containsKey(leadRecord.Id) && leadRecord.Status == 'Lead' && leadOldMap.get(leadRecord.Id).Status == 'New') {
                leadNewMap.get(leadRecord.Id).Date_in_Contacted_Status__c = Datetime.now();
            }
        }

    }

    public static void resetDaysInContactedField(Map<Id, Lead> leadNewMap, Map<Id, Lead> leadOldMap) {

        for (Lead leadRecord : leadNewMap.values()) {
            if (leadOldMap.containsKey(leadRecord.Id) && leadRecord.Status != 'Lead' && leadOldMap.get(leadRecord.Id).Status == 'Lead') {
                leadNewMap.get(leadRecord.Id).Date_in_Contacted_Status__c = null;
            }
        }
        
    }

    /***AUXILIAR METHODS***********************************************************************************************************************************/
    /***********************************AUXILIAR METHODS***************************************************************************************************/
    /********************************************************************AUXILIAR METHODS******************************************************************/

    public static List<DaysOfTheWeekClass> createDaysOfTheWeekList() {
        
        List<DaysOfTheWeekClass> listToReturn = new List<DaysOfTheWeekClass>();
        listToReturn.add(new DaysOfTheWeekClass('Sunday', 1, 'Sunday__c'));
        listToReturn.add(new DaysOfTheWeekClass('Monday', 2, 'Monday__c'));
        listToReturn.add(new DaysOfTheWeekClass('Tuesday', 3, 'Tuesday__c'));
        listToReturn.add(new DaysOfTheWeekClass('Wednesday', 4, 'Wednesday__c'));
        listToReturn.add(new DaysOfTheWeekClass('Thursday', 5, 'Thursday__c'));
        listToReturn.add(new DaysOfTheWeekClass('Friday', 6, 'Friday__c'));
        listToReturn.add(new DaysOfTheWeekClass('Saturday', 7, 'Saturday__c'));

        return listToReturn;

    }

    public class DaysOfTheWeekClass {

        public String nameOfTheDay;
        public Integer numberOfTheDay;
        public String apiNameOfTheDay;
    
        public DaysOfTheWeekClass(String nameDay, Integer numDay, String apiName) {
            nameOfTheDay = nameDay;
            numberOfTheDay = numDay;
            apiNameOfTheDay = apiName;
        }

    }

    public static String getApiNameOfDay(String nameOfTheDay, List<DaysOfTheWeekClass> listOfDays, Boolean afterHours) {

        String nameToReturn = '';
                
        if (!afterHours) {

            for (DaysOfTheWeekClass dayItem : listOfDays) {
                if (nameOfTheDay == dayItem.nameOfTheDay) {
                    nameToReturn = dayItem.apiNameOfTheDay;     
                }
            }

        } else {

            Integer numberDay = 0;
            for (DaysOfTheWeekClass dayItem : listOfDays) {
                if (nameOfTheDay == dayItem.nameOfTheDay) {
                    numberDay = dayItem.numberOfTheDay == 7 ? 1 : dayItem.numberOfTheDay + 1;
                    break;
                }
            }

            for (DaysOfTheWeekClass dayItem : listOfDays) {
                if (numberDay == dayItem.numberOfTheDay) {
                    nameToReturn = dayItem.apiNameOfTheDay;
                    break;
                }
            }

        }

        return nameToReturn;
    
    }

    public static String getOwnerId(List<Agents_Schedule__mdt> agentsWorkingNow) {

        String agentIdToReturn = '';

        List<String> agentsNames = new List<String>();
        for (Agents_Schedule__mdt agentItem : agentsWorkingNow) {
            agentsNames.add(agentItem.MasterLabel);
        }
        
        List<AggregateResult> leadsByOwner = [SELECT COUNT(OwnerId)NoOfLeads, Owner.Name
                                              FROM Lead
                                              WHERE Owner.Name != 'Aaron Navilli-Bryan'
                                              GROUP BY Owner.Name
                                              ORDER BY COUNT(OwnerId) ASC];

        if (!leadsByOwner.isEmpty()) {

            Set<String> agentsThatHaveLeads = new Set<String>();
            List<String> agentsThatDontHaveLeads = new List<String>();

            for (AggregateResult leadByOwner : leadsByOwner) {
                agentsThatHaveLeads.add(String.valueOf(leadByOwner.get('Name')));
            }

            agentsThatDontHaveLeads = getAgentsNamesMissing(agentsNames, agentsThatHaveLeads);

            if (agentsThatDontHaveLeads.isEmpty()) {

                String agentName = String.valueOf(leadsByOwner[0].get('Name'));
                User getUser = [SELECT Id FROM User WHERE Name =: agentName];
                agentIdToReturn = getUser.Id;

            } else {
                
                List<User> userList = [SELECT Id FROM User WHERE Name IN: agentsThatDontHaveLeads];
                if (!userList.isEmpty()) {
                    agentIdToReturn = userList[0].Id;
                }

            }
            
        } else {

            List<User> userList = [SELECT Id FROM User WHERE Name IN: agentsNames];
            if (!userList.isEmpty()) {
                agentIdToReturn = userList[0].Id;
            }

        }

        return agentIdToReturn;

    }

    public static List<String> getAgentsNamesMissing(List<String> agentsNames, Set<String> agentsThatHaveLeads) {

        List<String> listToReturn = new List<String>();
        
        for (String agent : agentsNames) {
            if (!agentsThatHaveLeads.contains(agent)) {
                listToReturn.add(agent);
            }
        }

        return listToReturn;

    }

}