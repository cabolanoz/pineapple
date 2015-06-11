module.exports = function(RefPerson) {

    RefPerson.findOperator = function(callback) {
        RefPerson.find(
            {
                where:
                {
                    'status_ind': 1,
                    'job_title_ind': 3
                },
                order: 'first_name ASC'
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

    RefPerson.remoteMethod(
        'findOperator',
        {
            description: 'Find a model instance by job title indicator from the data source',
            returns: { arg: 'id', type: 'object' },
            http: {verb: 'get'}
        }
    );

};
