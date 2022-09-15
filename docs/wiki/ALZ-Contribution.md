
## Contribution Guide

### Enterprise-Scale Committee
The Enterprise-Scale Committee and its members (aka Committee Members) are the primary caretakers of the Enterprise-Scale and AzOps repos including language, design, and reference implementations.

### Current Committee Members

- Uday Pandya @uday31in
- Kristian Nese @krnese
- Victor Arzate @victorar
- Johan Dahlbom @daltondhcp
- Lyon Till @ljtill
- Niels Buit @nielsams
- Hansjoerg Scherer @hjscherer 
- Callum Coffin @CalCof

### Committee Member Responsibilities

Committee Members are responsible for reviewing and approving RFCs proposing new features or design changes.

The initial Enterprise Committee consists of Microsoft employees. It is expected that over time, community will grow and new community members will join Committee Members. Membership is heavily dependent on the level of contribution and expertise: individuals who contribute in meaningful ways to the project will be recognized accordingly.

At any point in time, a Committee Member can nominate a strong community member to join the Committee. Nominations should be submitted in the form of RFCs detailing why that individual is qualified and how they will contribute. After the RFC has been discussed, a unanimous vote will be required for the new Committee Member to be confirmed.

### Contribution scope for Enterprise-Scale

The following is the scope of contributions to this repository:

As the Azure platform evolves and new services and features are validated in production with customers, the design guidelines will be updated in the overall architecture context.

With new Services, Resources, Resource properties and API versions, the implementation guide and reference implementation must be updated as appropriate.
Primarily, the code contribution would be centered on Azure Policy definitions and Azure Policy assignments for for Contoso Implementation.

Submit a pull request for documentation updates using the following template 'placeholder'.

#### How to submit Pull Request to upstream repo

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

### Code of Conduct

We are working hard to build strong and productive collaboration with our passionate community. We heard you loud and clear. We are working on set of principles and guidelines with Do's and Don'ts.
