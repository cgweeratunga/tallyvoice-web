# Terms of Service — working notes

Working record for `terms/index.html`, live at <https://tallyvoice.ai/terms/>.

**This file is deliberately excluded from deploys.** It is an internal
engineering record, not page content. It previously lived in an HTML comment at
the top of `index.html`, which shipped it to production, where anyone could read
it with view-source. `DEPLOY.md` holds the exclude list that keeps it off the
server — if you change how this site deploys, carry that exclusion across.

Everything below is verbatim from the comments it replaced. Category headings
were promoted to markdown headings and the index was added; no wording was
changed, reflowed or dropped, and closed items were kept. A second comment, the
entity and ABN verification record, was moved off the page on 2 Sep 2026 and is
at the end of this file.

---

## Index

**BLOCKING - unverified facts**

- [x] T1. OPERATOR LEGAL ENTITY AND ABN
- [x] T2. WHAT THE PRODUCT READS
- [x] T3. WHAT THE PRODUCT WRITES
- [x] T4. DRAFT-AND-CONFIRM MECHANICS
- [x] T5. BAS FIGURES

**BLOCKING - set at publish time**

- [x] T6. LAST UPDATED DATE

**UNCONFIRMED - does NOT block publishing. The unverified claim was left off the page rather than written down and flagged, so there is nothing on this page depending on the answer. Answer it to ADD a sentence, not to fix one.**

- [ ] T7. "THE ASSISTANT TELLS OWNERS IT CANNOT SEND REMINDERS." Not found.

**MARKETING COPY - does not block this page. ESCALATES, see the last paragraph of T8.**

- [ ] T8. THE HOMEPAGE SELLS REMINDERS.

**NOT BLOCKING - noticed while verifying, worth someone's attention**

- [ ] T9. USER_GUIDE.md CONTRADICTS THE PUBLISHED PRIVACY POLICY.

**ADDITIONS - not in the brief, flagged so they can be struck**

- [x] T10. Two sentences here were not asked for.
- [x] T11. DELIBERATELY ABSENT, per the brief: no pricing or billing terms

**8 closed, 3 open.**

---

## How to read this

```text
  ============================================================================
  TODO  -  Tally Voice Terms of Service
  Grep for "BEFORE-PUBLISH", "BEFORE-LAUNCH" and "UNCONFIRMED".

  Same two classes as the privacy policy, gating the same things:

    BEFORE-PUBLISH  this page MUST NOT go live while any of these is open.
    BEFORE-LAUNCH   a product/backend change. Does NOT block publishing this
                    page - the page describes today's behaviour accurately -
                    but MUST be done before the product is launched.

  Sibling document: /privacy/. Its TODO block covers the data side and is not
  repeated here. Item 13 there (the site-wide sticky header) applies to this
  page too - that is why the TOC on this page is not sticky either.
  ============================================================================
```

## BLOCKING - unverified facts

```text
  [x] T1. OPERATOR LEGAL ENTITY AND ABN - INFOLABS PTY LTD, ABN 61 615 110 346.
          Same entity and same ABN as the privacy policy, confirmed 30 Aug 2026
          against ABN Lookup; checksum validated. In section 1.
          If any entity other than Infolabs Pty Ltd appears anywhere on this
          page, it is a regression - fix it.

  [x] T2. WHAT THE PRODUCT READS - verified 1 Sep 2026 against the tool
          definitions in core/services/claude_qb.py. The tools that exist are
          get_daily_briefing, list_bills_owed, list_customers, list_suppliers,
          list_products_and_services, profit_and_loss and get_bas_due.
          Section 2 lists exactly these and nothing more.

  [x] T3. WHAT THE PRODUCT WRITES - verified 1 Sep 2026. Three write tools
          exist: prepare_invoice_draft, prepare_customer_draft,
          prepare_item_draft, each ending in a confirm step that calls
          QuickBooks (core/services/invoicing.py:370 create_invoice, and the
          equivalent in core/services/records.py).
          The write capability is stated in the lead paragraph, in the summary
          tiles, and in full in sections 2 and 3. It is deliberately NOT
          buried: an earlier round of pages understated this and had to be
          withdrawn. Do not move it further down the page.

  [x] T4. DRAFT-AND-CONFIRM MECHANICS - verified 1 Sep 2026 in the code.
          - Draft lifetime: core/models.py:180  DRAFT_TTL = timedelta(minutes=30)
          - Confirmation phrases: core/services/invoicing.py:42 CONFIRM_PHRASES
          - A bare "yes" is deliberately rejected: invoicing.py:37, and
            is_confirm_phrase() at :61-70.

          WORDING NOTE, read this before "correcting" section 3.
          The brief said "confirmation checks a phrase rather than accepting a
          bare yes". That is true of VOICE confirmation. It is not the whole
          mechanism: in the app, confirming is a deliberate button tap, and
          the phrase check does not apply (invoicing.py:338-340 - ``spoken``
          is None for the app, where confirming is a button tap).
          Section 3 therefore describes both doors separately, the same way
          the privacy policy describes the two voice paths separately. This is
          more accurate than the brief, not less - but it is a deviation from
          what was asked for, so it is recorded here rather than made quietly.

  [x] T5. BAS FIGURES - verified 1 Sep 2026. The BAS number is read from the
          Balance Sheet's GST/BAS liability accounts ("GST payable", "BAS
          suspense"), not from a TaxSummary report - core/services/claude_qb.py
          lines 38-44 and 824-842. Section 5 says exactly that. It matters,
          because a figure read off two liability accounts is an indication of
          what is sitting in the books, not a computed BAS.
```

## BLOCKING - set at publish time

```text
  [x] T6. LAST UPDATED DATE - SET 1 Sep 2026, the publish date. The hero
          reads "Last updated 1 September 2026". It replaced a deliberately
          glaring "BEFORE-PUBLISH - set the publish date" placeholder, which
          was there so this page could not go live with a plausible-looking
          wrong date the way the privacy policy nearly did.
          Section 10 tells readers this date is how they know whether the
          terms have changed, so it is load-bearing, not decoration.
          ON EVERY FUTURE EDIT: change it in the same commit. If a change is
          significant - what the service does, what it writes, or what the
          owner is responsible for - section 10 also promises an email to
          account holders. Both, or section 10 becomes false.
```

## UNCONFIRMED - does NOT block publishing. The unverified claim was left off the page rather than written down and flagged, so there is nothing on this page depending on the answer. Answer it to ADD a sentence, not to fix one.

```text
  [ ] T7. "THE ASSISTANT TELLS OWNERS IT CANNOT SEND REMINDERS." Not found.
          The brief stated that the assistant tells owners this and points
          them at QuickBooks' own reminder settings. Searched 1 Sep 2026:
          the string "remind" does not appear ANYWHERE in the pulsebooks
          repository - not in the system prompt, not in a tool description,
          not in a template. Zero matches, all file types.

          So section 4 states the limitation, which is verified and true, and
          points the READER at QuickBooks' reminder settings. It does not
          claim the assistant volunteers this, because nothing found supports
          that. If the behaviour does exist somewhere outside this repo, say
          where and the sentence can be added.
```

## MARKETING COPY - does not block this page. ESCALATES, see the last paragraph of T8.

```text
  [ ] T8. THE HOMEPAGE SELLS REMINDERS. THIS PAGE SAYS THEY DO NOT EXIST.
          Both will be live on the same domain, one click apart.

          DOWNGRADED 1 Sep 2026 from BLOCKING, on the product owner's word
          that the homepage pricing tiers are placeholder copy: no plans have
          been decided, none exist, and nobody has paid for anything. That
          removes the sharp version of this - a feature sold inside a paid
          plan that cannot be built - and leaves early-access marketing copy
          that oversells the product on a site with no customers. Still wrong,
          no longer a reason to withhold a page whose purpose is to describe
          the product accurately. Publishing Terms improves this situation;
          withholding it does nothing for the homepage.

          index.html advertises reminders in four places:
            :83   the phone demo's answer card has a "Prepare reminders" button
            :137  feature 04 - "prepare approved reminders from your mobile"
            :246  workflow step 4 - "Prepare reminders, reports, alerts"
            :283  Business plan feature - "Prepared invoice reminders"
          The app ships a dead button for it, by its own documentation:
            pulsebooks-app/docs/USER_GUIDE.md:175 - "the button is on the home
            screen but only says 'Reminders are coming soon'. It doesn't
            contact anyone."

          This is the same failure mode as understating the write capability,
          pointed the other way: the marketing page promises something the
          product cannot do. Section 4 is correct and MUST NOT be softened to
          make the homepage true - Terms describes what exists. Fix the
          homepage, or build reminders. Until one of those happens, a reader
          who compares the two pages finds the product page overselling and
          the terms correcting it.

          THIS GOES BACK TO BLOCKING THE MOMENT PRICING BECOMES REAL.
          The downgrade rests entirely on there being no paid plans and no
          customers. If a plan is published that lists reminders as an
          included feature - or if anyone is charged for a tier whose copy
          mentions them - this stops being marketing overreach and becomes a
          paid-for feature that does not exist. At that point it is blocking
          again, and it blocks the pricing page, not this one. Whoever sets
          pricing needs to see this item before the tiers go live.
```

## NOT BLOCKING - noticed while verifying, worth someone's attention

```text
  [ ] T9. USER_GUIDE.md CONTRADICTS THE PUBLISHED PRIVACY POLICY.
          pulsebooks-app/docs/USER_GUIDE.md:177 says "Chat history - the
          conversation is gone when you leave the chat screen or sign out.
          Nothing is saved between sessions."
          /privacy/ section 7 says messages are stored and kept for 365 days,
          verified against purge_chat_history. Those cannot both be true.
          The privacy policy was checked against the code and the guide was
          not, so the guide is the likely stale one - but it is a user-facing
          document making a retention claim, and it should be corrected rather
          than left to contradict the policy.
```

## ADDITIONS - not in the brief, flagged so they can be struck

```text
  [x] T10. Two sentences here were not asked for. Both are the minimum that
           makes a listed item mean anything, and neither invents a legal
           structure:
           - Section 1, one sentence: using the service means accepting these
             terms. Without it the document states rules that bind nobody.
             The privacy policy carries the equivalent line in its section 5.
           - Section 8, one sentence: we may suspend an account being used to
             break the law or to reach books the user has no right to.
             Acceptable use with no consequence attached is decoration.
           Strike either if unwanted. Nothing else on this page is unrequested.

  [x] T11. DELIBERATELY ABSENT, per the brief: no pricing or billing terms
           (nothing is charged yet), no imported warranty disclaimer, no
           arbitration clause, no indemnity, no limitation-of-liability
           section. If a lawyer later asks for any of these, that is a real
           decision to make - not an omission to quietly fix.
```

---

## Verification record — entity and ABN

**Not an open item.** This is a settled verification record, kept because it
names the source and the date the entity and ABN were checked against.

Moved verbatim out of `terms/index.html` on 2 Sep 2026, where it sat as an HTML
comment above section 1 and therefore shipped to production. The entity name and
the ABN are in the visible text of the page, so nothing was lost from it. This
comment carries no deliberate-omission note of its own — unlike the matching one
on the privacy policy, which recorded the GST decision — but it is still an
internal verification note, and the two pages should not disagree about whether
that kind of note ships. Both moved in the same change.

```text
            <!-- Entity and ABN confirmed 30 Aug 2026 against ABN Lookup:
                 INFOLABS PTY LTD, ABN 61 615 110 346, Australian Private Company,
                 active since 30 Sep 2016, main business location QLD.
                 ABN checksum verified. Same entity as the privacy policy. -->
```
