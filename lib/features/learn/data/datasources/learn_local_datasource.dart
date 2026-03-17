import '../models/lesson_step_model.dart';
import '../../domain/entities/lesson_topic.dart';

abstract class LearnLocalDataSource {
  Future<List<LessonStepModel>> getStepsForTopic(String topicId);
  Future<List<LessonOutcome>> getOutcomesForTopic(String topicId);
  Future<String> getCurrentTopicId();
  Future<void> setCurrentTopicId(String topicId);
  Future<Map<String, int>> getTopicProgress();
}

class LearnLocalDataSourceImpl implements LearnLocalDataSource {
  String _currentTopicId = 'saving';

  // ── Lesson steps ─────────────────────────────────────────
  static const _steps = <String, List<Map<String, dynamic>>>{
    'budgeting': [
      {
        'id': 'b1', 'order': 1,
        'title': 'What Is a Budget?',
        'body': 'A budget is a plan for your money. It shows how much comes in (income) and how much goes out (expenses) each month. Without a budget, money tends to disappear without explanation.',
        'example': 'Ana earns \$2,500/month. Her rent is \$900, food \$400, transport \$150. That leaves \$1,050 unplanned — a budget helps her decide what to do with it.',
        'tip': 'Even a rough budget beats no budget at all.',
      },
      {
        'id': 'b2', 'order': 2,
        'title': 'The 50/30/20 Rule',
        'body': 'A popular way to split your income: 50% goes to needs (rent, food, utilities), 30% goes to wants (dining out, entertainment), and 20% goes to savings and debt repayment.',
        'example': '\$2,500 income → \$1,250 for needs, \$750 for wants, \$500 for savings. Simple to remember, powerful to follow.',
        'tip': 'This rule is a starting point, not a strict law. Adjust it to your situation.',
      },
      {
        'id': 'b3', 'order': 3,
        'title': 'Tracking Your Spending',
        'body': 'Write down every purchase for one week. Most people are genuinely surprised by small, frequent expenses that add up silently over time.',
        'example': '3 coffees/week × \$4 = \$12/week = \$624/year. That\'s a weekend trip, a month of groceries, or a month of investing.',
        'tip': 'Small leaks sink big ships. Awareness is the first step to control.',
      },
    ],
    'saving': [
      {
        'id': 's1', 'order': 1,
        'title': 'Why Saving Matters',
        'body': 'Saving money isn\'t about being cheap — it\'s about buying freedom. Every dollar saved is a future option: to handle emergencies, seize opportunities, or simply worry less.',
        'example': 'Maria saves \$200/month. After 2 years she has \$4,800 — enough to handle a job transition or a medical bill without panic.',
        'tip': 'Savings = options. More savings = more choices in life.',
      },
      {
        'id': 's2', 'order': 2,
        'title': 'Pay Yourself First',
        'body': 'Instead of saving what\'s left after spending, save first and spend what\'s left. Automate a transfer to savings the same day your paycheck arrives, before you have a chance to spend it.',
        'example': 'Set up an automatic transfer of \$300 on every payday. After 6 months: \$1,800 saved with zero willpower required.',
        'tip': 'Automation removes the need for discipline. Make saving effortless.',
      },
      {
        'id': 's3', 'order': 3,
        'title': 'Where to Keep Savings',
        'body': 'A high-yield savings account earns significantly more interest than a standard checking account. Even a small difference in interest rate compounds meaningfully over years.',
        'example': '\$5,000 at 0.01% APY = \$0.50/year. Same amount in a HYSA at 5% APY = \$250/year.',
        'tip': 'Don\'t just save — save smarter. Where you keep it matters.',
      },
    ],
    'emergency': [
      {
        'id': 'e1', 'order': 1,
        'title': 'What Is an Emergency Fund?',
        'body': 'An emergency fund is money set aside exclusively for genuine unexpected expenses: job loss, medical emergencies, urgent car repairs. It\'s not vacation money or opportunity money.',
        'example': 'James loses his job unexpectedly. With a 3-month emergency fund (\$6,000), he pays rent and groceries while job searching — without going into debt.',
        'tip': 'An emergency fund converts panic situations into manageable ones.',
      },
      {
        'id': 'e2', 'order': 2,
        'title': 'How Much Do You Need?',
        'body': 'The standard recommendation is 3–6 months of essential living expenses. If you\'re self-employed or in a volatile industry, aim for 6–9 months. Start with \$1,000 as your first milestone.',
        'example': 'Monthly essentials: \$2,000. Target: \$6,000–\$12,000. First milestone: \$1,000 in 2–3 months.',
        'tip': 'Something is always better than nothing. Start small, build gradually.',
      },
      {
        'id': 'e3', 'order': 3,
        'title': 'Building It Step by Step',
        'body': 'Set a specific monthly savings target for your emergency fund. Keep it in a separate account so you\'re not tempted to spend it. Label the account "Emergency Only" as a psychological reminder.',
        'example': 'Save \$150/month → \$1,000 in 7 months → 3-month fund in 3.5 years.',
        'tip': 'Separate account, separate label. Out of sight, out of temptation.',
      },
    ],
    'credit': [
      {
        'id': 'c1', 'order': 1,
        'title': 'What Is a Credit Score?',
        'body': 'A credit score is a three-digit number (300–850) that tells lenders how likely you are to repay borrowed money. Higher scores unlock better loan rates, lower insurance premiums, and even rental approvals.',
        'example': 'Score 750: mortgage at 6.5%. Score 620: same mortgage at 8.2%. Over 30 years, that\'s \$80,000+ extra in interest.',
        'tip': 'Your credit score is one of the most valuable numbers in your financial life.',
      },
      {
        'id': 'c2', 'order': 2,
        'title': 'What Affects Your Score?',
        'body': 'Payment history (35%) is the biggest factor — always pay on time. Credit utilization (30%) means keeping balances below 30% of your limit. Length of history, new credit, and credit mix make up the rest.',
        'example': 'Limit: \$5,000. Balance: \$1,500 = 30% utilization (good). Balance: \$4,000 = 80% utilization (hurts score).',
        'tip': 'Pay on time. Keep balances low. These two habits cover 65% of your score.',
      },
      {
        'id': 'c3', 'order': 3,
        'title': 'Improving Your Score',
        'body': 'The fastest improvements come from paying down high balances and fixing payment history. Dispute errors on your report — they\'re more common than you think. Avoid closing old accounts.',
        'example': 'After 6 months of on-time payments and reduced balances, scores typically improve 30–60 points.',
        'tip': 'Credit scores are not permanent. Consistent good habits repair them reliably.',
      },
    ],
    'debt': [
      {
        'id': 'd1', 'order': 1,
        'title': 'Understanding Your Debt',
        'body': 'Before tackling debt, you need a complete picture: list every debt with its balance, interest rate, and minimum payment. Most people underestimate how much interest they\'re paying.',
        'example': 'Credit card \$3,000 at 22% APR. Minimum payment only: takes 11 years and costs \$3,900 in interest — more than the original debt.',
        'tip': 'Know your debt completely before making a plan.',
      },
      {
        'id': 'd2', 'order': 2,
        'title': 'Avalanche vs Snowball',
        'body': 'Avalanche: pay off highest interest debt first. Saves the most money mathematically. Snowball: pay off smallest balance first. Faster wins build psychological momentum.',
        'example': 'Avalanche saves \$1,200 in interest. Snowball: first debt paid in 3 months instead of 8. Both work — pick the one you\'ll actually stick to.',
        'tip': 'The best debt strategy is the one you follow through on.',
      },
      {
        'id': 'd3', 'order': 3,
        'title': 'Staying Out of Debt',
        'body': 'Paying off debt is only half the battle. Building the habits that prevent new debt is equally important: budget for irregular expenses, maintain your emergency fund, avoid lifestyle inflation.',
        'example': 'After paying off \$8,000 in credit card debt, redirecting those monthly payments into savings builds a \$9,600 fund in one year.',
        'tip': 'The habits that pay off debt are the same habits that build wealth.',
      },
    ],
    'investing': [
      {
        'id': 'i1', 'order': 1,
        'title': 'Why Invest?',
        'body': 'Savings accounts preserve money. Investments grow it. Over long periods, the stock market has historically returned around 7–10% annually after inflation. That compounds dramatically over decades.',
        'example': '\$10,000 at 8%/year: after 10 years = \$21,589. After 30 years = \$100,627. Same \$10,000 in savings at 2% = \$18,114.',
        'tip': 'Time in the market beats timing the market. Start early, even small.',
      },
      {
        'id': 'i2', 'order': 2,
        'title': 'Index Funds Explained',
        'body': 'An index fund buys tiny pieces of hundreds or thousands of companies at once. Instead of picking winners, you own the whole market. Low fees, automatic diversification, proven long-term performance.',
        'example': 'S&P 500 index fund: average annual return since 1957 ~10.5%. Warren Buffett recommends them for most investors.',
        'tip': 'Don\'t pick stocks. Buy the market. Keep fees below 0.1%.',
      },
      {
        'id': 'i3', 'order': 3,
        'title': 'Getting Started',
        'body': 'Open a brokerage account (Fidelity, Vanguard, or Schwab). Start with a target-date retirement fund or a simple S&P 500 index fund. Automate monthly contributions and don\'t panic during downturns.',
        'example': 'Invest \$300/month at age 25 at 8%/year: retire at 65 with \$1,007,000. Starting at 35: \$440,000. A decade matters enormously.',
        'tip': 'Start today. Automate it. Don\'t touch it for decades.',
      },
    ],
    'retirement': [
      {
        'id': 'r1', 'order': 1,
        'title': 'Retirement Basics',
        'body': 'Retirement planning is about ensuring your savings outlast you. The key variables are: when you retire, how much you spend, how much you\'ve saved, and your investment returns.',
        'example': '\$1 million saved. 4% withdrawal rate = \$40,000/year for 30+ years (the "4% rule"). Adjust for Social Security and other income.',
        'tip': 'Retirement planning is mostly math — and the math is learnable.',
      },
      {
        'id': 'r2', 'order': 2,
        'title': '401(k) and IRA',
        'body': 'Tax-advantaged accounts are the most powerful retirement tools. 401(k): employer match is free money — always contribute enough to get the full match. IRA: additional \$7,000/year you can invest tax-advantaged.',
        'example': 'Employer matches 3% of \$60k salary = \$1,800/year free. Over 30 years at 7%: \$181,000 from employer match alone.',
        'tip': 'Employer match is an instant 50–100% return. Never leave it on the table.',
      },
      {
        'id': 'r3', 'order': 3,
        'title': 'Road to Financial Independence',
        'body': 'Financial independence means your investments generate enough income that work becomes optional. Your savings rate, not your income, determines your timeline.',
        'example': 'Save 50% of income → retire in ~17 years. Save 25% → retire in ~32 years.',
        'tip': 'Financial independence is a mindset as much as a number.',
      },
    ],
  };

  // ── Learning outcomes ─────────────────────────────────────
  static const _outcomes = <String, List<String>>{
    'budgeting': [
      'Understand what a budget is and why it matters',
      'Apply the 50/30/20 rule to your income',
      'Track spending and spot hidden costs',
    ],
    'saving': [
      'Discover why saving = freedom, not sacrifice',
      'Use the pay-yourself-first strategy',
      'Choose the right account to grow savings',
    ],
    'emergency': [
      'Define what counts as a true emergency',
      'Calculate your target emergency fund amount',
      'Build your fund step-by-step without stress',
    ],
    'credit': [
      'Know what a credit score is and who sees it',
      'Identify the five factors that affect your score',
      'Take concrete steps to raise your score',
    ],
    'debt': [
      'Map every debt with balance and interest rate',
      'Choose between avalanche and snowball methods',
      'Build habits that prevent debt from coming back',
    ],
    'investing': [
      'Understand why investing beats saving alone',
      'Learn how index funds work and why they win',
      'Open an account and make your first investment',
    ],
    'retirement': [
      'Grasp the key variables in retirement planning',
      'Maximise your 401(k) and IRA contributions',
      'Calculate how your savings rate affects timeline',
    ],
  };

  @override
  Future<List<LessonStepModel>> getStepsForTopic(String topicId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final raw = _steps[topicId] ?? [];
    return raw
        .map((j) => LessonStepModel.fromJson(Map<String, dynamic>.from(j)))
        .toList();
  }

  @override
  Future<List<LessonOutcome>> getOutcomesForTopic(String topicId) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final texts = _outcomes[topicId] ?? [];
    return texts.map((t) => LessonOutcome(text: t)).toList();
  }

  @override
  Future<String> getCurrentTopicId() async => _currentTopicId;

  @override
  Future<void> setCurrentTopicId(String topicId) async {
    _currentTopicId = topicId;
  }

  @override
  Future<Map<String, int>> getTopicProgress() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return {'saving': 1};
  }
}