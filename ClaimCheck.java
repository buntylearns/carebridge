public class ClaimCheck {

    public static void main(String[] args) {
        String patientName = "John Smith";
        int age = 25;
        boolean insuranceActive = true;
        double deductibleRemaining = 500.0;
        System.out.println("Single Claim");
        System.out.println("Patient:" + patientName + " (" + age + ") " + " | Insurance:" + insuranceActive + " | Deductible left: $" + deductibleRemaining);
        double claimAmount = 320.0;

        if (!insuranceActive) {
            System.out.println("DENIED - inactive policy");
        } else if (claimAmount <= deductibleRemaining) {
            System.out.println("PATIENT PAYS: $" + claimAmount);
            deductibleRemaining = deductibleRemaining - claimAmount;
            System.out.println("REMAINING DEDUCTIBLE: $" + deductibleRemaining);
        } else {
            double patientPays = claimAmount - deductibleRemaining;
            System.out.println("PATIENT PAYS: $" + patientPays);
            deductibleRemaining = 0;
            System.out.println("REMAINING DEDUCTIBLE: $" + deductibleRemaining);
        }
System.out.println("Multiple Claim");
double[] claims = {320.00, 150.00, 890.00, 200.00};
double deductibleRemaining2 = 500.0;
double planPaidTotal = 0;

if (!insuranceActive) {
    System.out.println("DENIED - inactive policy");
} else {
    for (int i = 0; i < claims.length; i++) {
        double currentClaim = claims[i];
        if (currentClaim <= deductibleRemaining2) {
            deductibleRemaining2 = deductibleRemaining2 - currentClaim;
            System.out.println("PATIENT PAYS: $" + currentClaim
                + " -> REMAINING DEDUCTIBLE: $" + deductibleRemaining2);
        } else {
            double patientShare = deductibleRemaining2;
            double planShare = currentClaim - deductibleRemaining2;
            planPaidTotal = planPaidTotal + planShare;
            deductibleRemaining2 = 0;
            System.out.println("PATIENT PAYS: $" + patientShare
                + " | PLAN PAYS: $" + planShare
                + " -> REMAINING DEDUCTIBLE: $" + deductibleRemaining2);
        }
    }
    System.out.println("PLAN PAID TODAY: $" + planPaidTotal);
}

    }
}