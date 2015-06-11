module.exports = function(OpsItinerary) {

    OpsItinerary.findOneWithRelatedModel = function(id, callback) {
        OpsItinerary.findOne(
            {
                where:
                {
                    'itinerary_num': id,
                    'status_ind': 1
                },
                include:
                {
                    'operator_person': '',

                    'internal_company': '',
                    'movement':
                    {
                        'mot': '',
                        'depart_location': '',
                        'arrive_location': '',
                        'movement_status': '',
                        'cargo': {
                            'cargo_type': '',
                            'strategy': '',
                            'valuation_type': '',
                            'cmdty': '',
                            'qty_uom': '',
                            'price_curr': '',
                            'price_uom': ''
                        }
                    }
                }
            },
            callback
        );
    };

    OpsItinerary.remoteMethod(
        'findOneWithRelatedModel',
        {
            description: 'Find a model instance with its related dependencies by itinerary number from the data source',
            accepts: { arg: 'id', type: 'number', description: 'Model id', required: true, root: true },
            returns: { arg: 'id', type: 'object' },
            http: { verb: 'get' }
        }
    );

    OpsItinerary.findFirstTenWithRelatedModel = function(callback) {
        OpsItinerary.find(
            {
                order: 'itinerary_num DESC',
                limit: 15,
                include:
                {
                    'operator_person': '',

                    'internal_company': '',
                    'movement':
                    {
                        'mot': '',
                        'depart_location': '',
                        'arrive_location': '',
                        'cargo': {
                            'strategy': '',
                            'valuation_type': '',
                            'cmdty': '',
                            'qty_uom': '',
                            'price_curr': '',
                            'price_uom': ''
                        }
                    }
                }

            },
            callback
        );
    };

    OpsItinerary.remoteMethod(
        'findFirstTenWithRelatedModel',
        {
            description: 'Find the first ten model instances with its related dependencies from the data source',
            returns: { arg: 'id', type: 'object' },
            http: { verb: 'get' }
        }
    );

};
