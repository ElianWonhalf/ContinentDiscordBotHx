package model.entity;

import model.Entity.EntityProperties;

class Subreddit extends Entity {
    public static var properties: EntityProperties = {
        tableName: 'subreddit',
        tableColumns: [
            {
                name: 'id',
                mappedBy: 'id',
                primary: true
            },
            {
                name: 'name',
                mappedBy: 'name',
                primary: false
            },
            {
                name: 'refresh_interval',
                mappedBy: 'refreshInterval',
                primary: false
            }
        ]
    };

    public var id: Int;
    public var name: String;
    public var refreshInterval: Int;
}
