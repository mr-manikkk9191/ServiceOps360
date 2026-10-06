// Demo data: skills, technicians (around Chandigarh/Mohali), parts, sample requests.
Map<String, Skill__c> skills = new Map<String, Skill__c>();
for (String n : new List<String>{ 'AC Repair', 'Electrical', 'Plumbing', 'Appliance Repair', 'Refrigeration', 'Networking' }) {
    skills.put(n, new Skill__c(Name = n));
}
insert skills.values();

List<Technician__c> techs = new List<Technician__c>{
    new Technician__c(Name = 'Aman Sharma', Email__c = 'aman@example.com', Phone__c = '9800000001', Status__c = 'AVAILABLE', Experience_Years__c = 6, Latitude__c = 30.7046, Longitude__c = 76.7179),
    new Technician__c(Name = 'Ritu Verma', Email__c = 'ritu@example.com', Phone__c = '9800000002', Status__c = 'AVAILABLE', Experience_Years__c = 4, Latitude__c = 30.7333, Longitude__c = 76.7794),
    new Technician__c(Name = 'Karan Singh', Email__c = 'karan@example.com', Phone__c = '9800000003', Status__c = 'AVAILABLE', Experience_Years__c = 9, Latitude__c = 30.6942, Longitude__c = 76.8606),
    new Technician__c(Name = 'Neha Gupta', Email__c = 'neha@example.com', Phone__c = '9800000004', Status__c = 'OFFLINE', Experience_Years__c = 3, Latitude__c = 30.7500, Longitude__c = 76.7800)
};
insert techs;

insert new List<Technician_Skill__c>{
    new Technician_Skill__c(Technician__c = techs[0].Id, Skill__c = skills.get('AC Repair').Id),
    new Technician_Skill__c(Technician__c = techs[0].Id, Skill__c = skills.get('Refrigeration').Id),
    new Technician_Skill__c(Technician__c = techs[1].Id, Skill__c = skills.get('AC Repair').Id),
    new Technician_Skill__c(Technician__c = techs[1].Id, Skill__c = skills.get('Electrical').Id),
    new Technician_Skill__c(Technician__c = techs[2].Id, Skill__c = skills.get('Plumbing').Id),
    new Technician_Skill__c(Technician__c = techs[2].Id, Skill__c = skills.get('Appliance Repair').Id),
    new Technician_Skill__c(Technician__c = techs[3].Id, Skill__c = skills.get('Networking').Id)
};

insert new List<Part__c>{
    new Part__c(Name = 'AC Capacitor 35uF', SKU__c = 'AC-CAP-35', Unit_Cost__c = 600, Current_Stock__c = 12, Reorder_Level__c = 4, Warehouse__c = 'Mohali Main'),
    new Part__c(Name = 'Refrigerant Gas R32 (1kg)', SKU__c = 'GAS-R32-1', Unit_Cost__c = 1200, Current_Stock__c = 6, Reorder_Level__c = 3, Warehouse__c = 'Mohali Main'),
    new Part__c(Name = 'Pipe Fitting 1/2 inch', SKU__c = 'PL-PIPE-12', Unit_Cost__c = 150, Current_Stock__c = 40, Reorder_Level__c = 10, Warehouse__c = 'Chandigarh Store')
};

insert new List<Case>{
    new Case(Subject = 'AC not cooling', Origin = 'Phone', Priority = 'High', Service_Category__c = 'AC Repair', Location_Latitude__c = 30.7400, Location_Longitude__c = 76.7900, Description = 'Split AC runs but does not cool.'),
    new Case(Subject = 'Kitchen tap leaking', Origin = 'Web', Priority = 'Medium', Service_Category__c = 'Plumbing', Location_Latitude__c = 30.7100, Location_Longitude__c = 76.7200),
    new Case(Subject = 'Office Wi-Fi down', Origin = 'Email', Priority = 'Critical', Service_Category__c = 'Networking', Location_Latitude__c = 30.7300, Location_Longitude__c = 76.7700)
};
System.debug('Seed data created.');
