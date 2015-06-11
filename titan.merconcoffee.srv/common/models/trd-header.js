module.exports = function(TrdHeader) {

    TrdHeader.findOneWithRelatedModel = function(id, callback) {
        TrdHeader.findOne(
            {
                where:
                {
                    'trade_num': id,
                    'trade_type_cd': 'Coffee Contract',
                    'trade_status_ind': {
                        nin:
                        [
                            5
                        ]
                    }
                },
                include:
                {
                    'internal_side': '',
                    'strategy': '',
                    'counterpart_company': '',
                    'broker_company': '',
                    'trader_person': '',
                    'internal_company': '',
                    'obligation_hdr':
                    [
                        'strategy',
                        'internal_co'
                    ]
                }
            },
            callback
        );
    };

    TrdHeader.remoteMethod(
        'findOneWithRelatedModel',
        {
            description: 'Find a model instance with its related dependencies by trade number from the data source',
            accepts: { arg: 'id', type: 'number', description: 'Model id', required: true, root: true },
            returns: { arg: 'id', type: 'object' },
            http: { verb: 'get' }
        }
    );

    TrdHeader.findWithRelatedModel = function(filter, callback) {
        var _results = new Array();

        var _str = filter.split(",");

        if (_str.length > 0) {
            for (var i = 0; i < _str.length; i++) {
                _results.push(parseInt(_str[i].trim()));
            }
        } else {
           _results.push(parseInt(filter.trim()));
        }

        TrdHeader.find(
            {
                where:
                {
                    'trade_num': {
                        inq:
                        [
                            _results
                        ]
                    },
                    'trade_type_cd': 'Coffee Contract',
                    'trade_status_ind': {
                        nin:
                            [
                                5
                            ]
                    }
                },
                include:
                {
                    'internal_side': '',
                    'strategy': '',
                    'counterpart_company': '',
                    'broker_company': '',
                    'trader_person': '',
                    'internal_company': '',
                    'obligation_hdr':
                        [
                            'strategy',
                            'internal_co'
                        ]
                }
            },
            callback
        );
    };

    TrdHeader.remoteMethod(
        'findWithRelatedModel',
        {
            description: 'Find all instances of the model with its related dependencies matched by filter from the data source',
            accepts: { arg: 'filter', type: 'string', description: 'Filter defining fields, where, orderBy, offset, and limit', required: true },
            returns: { arg: 'id', type: 'object' },
            http: { verb: 'get' }
        }
    );

};
