trigger AppendFieldsToChatter on FeedItem (before insert) {
    // Get the custom settings for objects that should have fields appended
    List<ChatterAppendObjectField__c> customSettings = [SELECT Object__c, Field_s__c, Field_Labels__c FROM ChatterAppendObjectField__c];

    // Create a map to hold custom setting values for quick access
    Map<String, ChatterAppendObjectField__c> objectSettingsMap = new Map<String, ChatterAppendObjectField__c>();
    for (ChatterAppendObjectField__c setting : customSettings) {
        objectSettingsMap.put(setting.Object__c, setting);
    }

    for (FeedItem feedItem : Trigger.new) {
        if (feedItem.ParentId != null) {
            String parentId = feedItem.ParentId;
            String parentObjectType = feedItem.ParentId.getSObjectType().getDescribe().getName();
            
            if (objectSettingsMap.containsKey(parentObjectType)) {
                ChatterAppendObjectField__c customSetting = objectSettingsMap.get(parentObjectType);

                // Split fields and field labels from the custom settings
                List<String> fields = customSetting.Field_s__c.split(',');
                List<String> fieldLabels = customSetting.Field_Labels__c != null ? customSetting.Field_Labels__c.split(',') : new List<String>();

                // Ensure labels list has the same size as fields list; if not, use field name as fallback
                while (fieldLabels.size() < fields.size()) {
                    fieldLabels.add(fields[fieldLabels.size()].trim());
                }

                // Combine all fields for the SOQL query
                List<String> allFields = new List<String>();
                List<String> relationshipFields = new List<String>();

                for (String field : fields) {
                    if (field.contains('.')) {
                        relationshipFields.add(field.trim());
                    } else {
                        allFields.add(field.trim());
                    }
                }

                allFields.addAll(relationshipFields);

                // Query the parent object with selected fields
                String soql = 'SELECT ' + String.join(allFields, ',') + ' FROM ' + parentObjectType + ' WHERE Id = :parentId LIMIT 1';
                SObject parentObject;
                try {
                    parentObject = Database.query(soql);
                    System.debug('Queried parent object: ' + parentObject);
                } catch (Exception e) {
                    System.debug('Error querying parent object: ' + e.getMessage());
                    continue;
                }

                String appendedMessage = '<ul>';

                // Process fields, ensuring correct matching with labels
                for (Integer i = 0; i < fields.size(); i++) {
                    String fieldName = fields[i].trim();
                    String fieldLabel = (i < fieldLabels.size()) ? fieldLabels[i].trim() : fieldName;
                    System.debug('Processing field: ' + fieldName + ' with label: ' + fieldLabel);

                    try {
                        Object fieldValue;
                        if (fieldName.contains('.')) {
                            // For relationship fields
                            fieldValue = AppendFieldsToChatterHelper.getNestedFieldValue(parentObject, fieldName);
                        } else {
                            // For direct fields
                            fieldValue = parentObject.get(fieldName);
                        }
                        
                        // Ensure label is present, and if field value is null, display N/A
                        appendedMessage += '<li><b>' + fieldLabel + ':</b> ' + (fieldValue != null ? String.valueOf(fieldValue) : 'N/A') + '</li>';
                    } catch (Exception e) {
                        System.debug('Error processing field: ' + fieldName + '. Exception: ' + e.getMessage());
                        appendedMessage += '<li><b>' + fieldLabel + ':</b> N/A</li>';
                    }
                }

                appendedMessage += '</ul>';
                feedItem.Body = appendedMessage + feedItem.Body;
            }
        }
    }
}