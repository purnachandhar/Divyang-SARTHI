class IepAssessmentModel {
  final List<IepDomain> domains;

  IepAssessmentModel({
    required this.domains,
  });

  factory IepAssessmentModel.fromJson(Map<String, dynamic> json) {
    var list = json['domains'] as List? ?? [];
    List<IepDomain> domainList =
        list.map((i) => IepDomain.fromJson(i)).toList();

    return IepAssessmentModel(
      domains: domainList,
    );
  }
}

class IepDomain {
  final String domainName;
  final String domainId;
  final String domainIcon;
  final String subdomain;
  final List<IepQuestion> questions;
  final int questionsCount;

  IepDomain({
    required this.domainName,
    required this.domainId,
    required this.domainIcon,
    required this.subdomain,
    required this.questions,
    required this.questionsCount,
  });

  factory IepDomain.fromJson(Map<String, dynamic> json) {
    var list = json['questions'] as List? ?? [];
    List<IepQuestion> questionList =
        list.map((i) => IepQuestion.fromJson(i)).toList();

    return IepDomain(
      domainName: json['domainName'] ?? 'No Domain Name',
      domainId: json['domainId'] ?? '',
      domainIcon: json['domainIcon'] ?? '',
      subdomain: json['subdomain'] ?? '',
      questions: questionList,
      questionsCount: json['questionsCount'] ?? 0,
    );
  }
}

class IepQuestion {
  final String id;
  final String question;
  final List<String> options;
  final String subdomain;
  final String agegroup;

  IepQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.subdomain,
    required this.agegroup,
  });

  factory IepQuestion.fromJson(Map<String, dynamic> json) {
    var opts = json['options'] as List? ?? [];
    List<String> optionList = opts.map((o) => o.toString()).toList();

    return IepQuestion(
      id: json['_id'] ?? json['id'] ?? '',
      question: json['question'] ?? 'No Question Text',
      options: optionList,
      subdomain: json['subdomain'] ?? '',
      agegroup: json['agegroup'] ?? '',
    );
  }
}
