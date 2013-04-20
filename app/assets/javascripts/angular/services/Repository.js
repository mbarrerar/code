(function(code) {

    code.factory("Repository", ["$resource", function($resource) {
        var Repository = $resource(
            "/api/repositories/:id",
            { id: "@id" }
        );

//        Applicant.prototype.name = function() {
//            return this.last_name + ", " + this.first_name;
//        };
//
//        Applicant.prototype.isFinalist = function() {
//            return this.assessment_id == 10 || this.assessment_id == 11;
//        };

        return Repository;
    }]);

})(window.code);
