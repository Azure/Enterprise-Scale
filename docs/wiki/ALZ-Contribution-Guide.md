# Contributing to Azure landing zones (Enterprise-Scale)

Firstly, thank you for taking the time to contribute!

The Azure landing zones reference implementation is designed to help customers accelerate their cloud adoption journey.
By contributing to this solution, you can help our customers get the best out of this experience.

We actively encourage community contributions as we realize the unique and diverse requirements of our customers can help drive a better outcome for everyone.

The following is a set of guidelines for contributing to this repository.

## Committee of maintainers

Contributions to this repository are moderated by a committee of maintainers.
The committee is responsible for reviewing and approving all contributions, whether via GitHub issues, pull requests, or internally driven requests.

The committee is also responsible for reviewing and sponsoring new features or design changes to ensure they meet the needs of our broad community of consumers.
This ensure the reference implementation continues to deliver against the Azure landing zones recommendations, as documented on the Cloud Adoption Framework.

The initial committee consists of Microsoft employees only.
It is expected that over time, community contributions will grow and new community members will join as committee members.
Membership is heavily dependent on the level of contribution and expertise: individuals who contribute in meaningful ways to the project will be recognized accordingly.

At any point in time, a committee member can nominate a strong community member to join the committee.
Nominations should be submitted in the form of RFCs detailing why that individual is qualified and how they will contribute.
After the RFC has been discussed, a unanimous vote will be required for the new committee member to be confirmed.

## Contributors

As an open source project, the reference implementation works best when it reflects the needs of our community of consumers.
As such, we welcome contributions however big or small.
All we ask is that you follow some simple guidelines, including participating according to our [code of conduct](https://github.com/Azure/Enterprise-Scale/blob/main/CODE_OF_CONDUCT.md).

## Contribution scope

The following is the scope of contributions to this repository:

As the Azure platform evolves and new services and features are validated in production with customers, the design guidelines will be updated in the overall architecture context.

With new Services, Resources, Resource properties and API versions, the implementation guide and reference implementation must be updated as appropriate.
Primarily, the code contribution would be centered on Azure Policy definitions and Azure Policy assignments for the reference implementation.

Submit a pull request for documentation updates using the following template 'placeholder'.

### How to submit Pull Request to upstream repo

1. Create a new branch based on upstream/main by executing following command

    ```shell
    git checkout -b feature upstream/main
    ```

2. Checkout the file(s) from your working branch that you may want to include in PR

    ```shell
    #substitute file name as appropriate. below example
    git checkout feature: .\.docs\Deploy\Deploy-lz.md
    ```

3. Push your Git branch to your origin

    ```shell
    git push origin -u
    ```

4. Create a pull request from upstream to your remote main

## Code of Conduct

We are working hard to build strong and productive collaboration with our passionate community. We heard you loud and clear. We are working on set of principles and guidelines with Do's and Don'ts.
