module.exports = function(RefCompany) {

    RefCompany.findInternalCompanies = function(callback) {
        RefCompany.find(
            {
                where:
                {
                    'status_ind': 1,
                    'restricted_ind': 0,
                    'company_type_ind': 10
                },
                order: 'company_cd ASC'
            },
            function(err, id)
            {
                if (err) {
                    next(err);
                } else {
                    callback(null, id);
                }
            }
        );
    };

    RefCompany.remoteMethod(
        'findInternalCompanies',
        {
            description: 'Find a model instance by company type indicator from the data source',
            returns: { arg: 'id', type: 'object' },
            http: {verb: 'get'}
        }
    );

};
