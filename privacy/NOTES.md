# Privacy Policy — working notes

Working record for `privacy/index.html`, live at <https://tallyvoice.ai/privacy/>.

**This file is deliberately excluded from deploys.** It is an internal
engineering record, not page content. It previously lived in an HTML comment at
the top of `index.html`, which shipped it to production, where anyone could read
it with view-source. `DEPLOY.md` holds the exclude list that keeps it off the
server — if you change how this site deploys, carry that exclusion across.

Everything below is verbatim from the comments it replaced. Category headings
were promoted to markdown headings and the index was added; no wording was
changed, reflowed or dropped, and closed items were kept.

Two further comments were moved here on 2 Sep 2026, both verbatim: the entity and
ABN verification record, which was on the page above section 1 and is at the end
of this file; and the STICKY TOC note from the `legal.css` header block, which is
filed beside item 13, the sticky-header item it refers to.

---

## Index

**BLOCKING - unverified facts**

- [x] 1. OPERATOR LEGAL ENTITY
- [x] 2. ABN

**BLOCKING - sections not yet written, pending production code review**

- [x] 3. VOICE TRANSCRIPTS
- [x] 4. RETENTION / DELETION SCOPE
- [x] 5. ACCOUNT DATA

**BLOCKING - no delete-account route exists**

- [x] 7. DELETE ACCOUNT

**SECURITY - not a policy item. Must not get lost.**

- [ ] 8. QUICKBOOKS OAUTH TOKENS ARE STORED IN PLAINTEXT.
- [x] 9. THIRD-PARTY CONTACT DETAILS IN RecordDraft

**BLOCKING - infrastructure**

- [x] 6. CONTACT EMAIL

**BLOCKING - set at publish time**

- [x] 11. LAST UPDATED DATE

**BEFORE-LAUNCH - product change. Does not block publishing this page.**

- [ ] 12. THE EARLY-ACCESS FORM RECORDS NOTHING, AND TELLS PEOPLE IT DID.
- [ ] 10. SCRUB SPENT DRAFTS.

**SITE FIX - its own change, its own test. Not part of the legal page.**

- [ ] 13. THE STICKY HEADER DOES NOT STICK, SITE-WIDE.

**NOT BLOCKING - verified, no action needed**

- [x] Backups (section 9)
- [x] Cookies / analytics

**11 closed, 4 open.**

---

## How to read this

```text
  ============================================================================
  TODO  -  Tally Voice Privacy Policy
  Grep for "BEFORE-PUBLISH", "BEFORE-LAUNCH" and "UNCONFIRMED".

  Two classes of item below, and they gate different things:

    BEFORE-PUBLISH  this page MUST NOT go live while any of these is open.
    BEFORE-LAUNCH   a product/backend change. Does NOT block publishing this
                    page - the page describes today's behaviour accurately -
                    but MUST be done before the product is launched, and the
                    wording it unblocks is noted on the item.
  ============================================================================
```

## BLOCKING - unverified facts

```text
  [x] 1. OPERATOR LEGAL ENTITY - CONFIRMED 30 Aug 2026 against ABN Lookup.
         INFOLABS PTY LTD. Australian Private Company, active since
         30 Sep 2016, main business location QLD.
         NOTE: an earlier draft of this policy named a DIFFERENT company as
         the operator. That was wrong. If any entity other than Infolabs Pty
         Ltd appears anywhere on this page, it is a regression - fix it.
         Infolabs is not registered for GST. That is deliberately not written
         into the policy; GST status is not a privacy matter.

  [x] 2. ABN - CONFIRMED 30 Aug 2026: 61 615 110 346, for INFOLABS PTY LTD.
         Checksum validated (weighted sum 356, mod 89 = 0). In section 1.
```

## BLOCKING - sections not yet written, pending production code review

```text
  [x] 3. VOICE TRANSCRIPTS - SETTLED 30 Aug 2026, confirmed against the code.
         TWO PATHS, DIFFERENT OUTCOMES, and only one of them is intuitive:
         - APP REALTIME VOICE (mic button): nothing stored. No audio, no
           transcript, no Message row. The WebView voice page talks to narrow
           realtime tool endpoints and never reaches answer_question, which is
           the only code path that records a turn.
           (core/services/conversation.py:10, and the Conversation docstring.)
         - TELEGRAM VOICE NOTES: run_bot.py transcribes the note and hands the
           TEXT to answer_question as an ordinary question with
           channel=TELEGRAM (run_bot.py:249). Audio discarded; the WORDS are
           stored as a Message row and live 365 days like a typed question.
         Section 3 now states audio and words SEPARATELY for each path, in two
         callouts, and closes with "if you send a voice note to the Telegram
         bot, assume the words are written down, because they are".
         Section 2 cross-references it. Section 3's heading changed from
         "We do not record your voice" to "We never keep a recording of your
         voice" - the old one invited the reading that nothing is kept.

  [x] 4. RETENTION / DELETION SCOPE - SETTLED, verified in code 28 Aug 2026.
         purge_chat_history deletes Message rows ONLY (filtered on
         created_at); Conversation rows are deliberately left alone.
         clear_conversation() likewise deletes Message rows only. Nothing
         deletes InvoiceDraft or RecordDraft.
         Section 7 rewritten: 365 days covers messages and nothing else;
         profile/account data kept until the account is deleted; draft rows
         kept indefinitely and called out as such.

  [x] 5. ACCOUNT DATA - SETTLED 28 Aug 2026. Section 2 now covers the account
         (email, hashed password, name, business name, plan, BAS settings),
         the QuickBooks connection (company identifier + tokens, with an
         accurate description of what protects them) and the Telegram link
         (chat ID, user ID, username, first name, 10-minute link codes).
```

## BLOCKING - no delete-account route exists

```text
  [x] 7. DELETE ACCOUNT - CLOSED 30 Aug 2026 as a publishing blocker.
         There is still NO self-serve flow (verified 28 Aug: no
         delete_account view, no URL route containing "delete"; nothing
         deletes auth_user, Customer, InvoiceDraft or RecordDraft).
         What closed it: the client has committed to actioning deletion
         requests BY HAND, and the mailbox is live (item 6).
         Section 8 promises exactly that and no more: email us and we will
         delete your account and everything in it, done by hand, confirmed
         when done. NO turnaround time is promised anywhere in the policy -
         do not add one unless it is a commitment you can keep.
         Still worth building a self-serve flow. No longer blocking.
```

## SECURITY - not a policy item. Must not get lost.

```text
  [ ] 8. QUICKBOOKS OAUTH TOKENS ARE STORED IN PLAINTEXT.
         Verified 28 Aug 2026: core/models.py QBConnection.refresh_token and
         .access_token are plain CharFields. There is no application-level
         encryption anywhere in the codebase - grep for encrypt / Fernet /
         EncryptedCharField returns nothing. At rest they are protected only
         by disk and database access control.
         Intuit's compliance questionnaire asks how OAuth tokens are stored.
         This is the honest answer to that question, and it is weak.
         The policy has been written to describe what actually protects the
         connection (DB not internet-reachable, user can revoke from inside
         QuickBooks) and makes NO encryption claim anywhere. Do not add one
         until this is actually fixed.
         Fix is a backend change (field-level encryption with a key supplied
         from the environment, plus a re-encrypt migration for existing rows)
         - out of scope for the policy work, tracked here so it survives.

  [x] 9. THIRD-PARTY CONTACT DETAILS IN RecordDraft - DISCLOSED 28 Aug 2026.
         RecordDraft.payload for kind="customer" holds a third party's name,
         email, phone and address - the owner's customer, who never signed up,
         never agreed to anything with us, and does not know we hold their
         details. Sections 3 and 7 now say so.
         Disclosure is done. THE FIX IS ITEM 10 (BEFORE-LAUNCH).
```

## BLOCKING - infrastructure

```text
  [x] 6. CONTACT EMAIL - LIVE, confirmed by client 30 Aug 2026.
         hello@tallyvoice.ai now receives mail. Appears in section 10
         (complaints) and section 13 (contact), and is now also the route for
         account deletion requests in section 8 - see item 7.
```

## BLOCKING - set at publish time

```text
  [x] 11. LAST UPDATED DATE - SET 1 Sep 2026, the publish date. The hero
          reads "Last updated 1 September 2026".
          Section 12 tells readers this date is how they know whether the
          policy has changed, so it is load-bearing, not decoration.
          ON EVERY FUTURE EDIT: change it in the same commit. If a change is
          significant - what is stored, where it goes, how long it is kept -
          section 12 also promises an email to account holders. Both, or
          section 12 becomes false.
```

## BEFORE-LAUNCH - product change. Does not block publishing this page.

```text
  [ ] 12. THE EARLY-ACCESS FORM RECORDS NOTHING, AND TELLS PEOPLE IT DID.
          Verified 1 Sep 2026 in script.js lines 31-39. On submit it calls
          event.preventDefault(), reads the form data into a local variable,
          sets the message "Thanks {name}. Your early-access request has been
          recorded.", and resets the form. There is no fetch, no action
          attribute, no mailto, no storage. NOTHING IS TRANSMITTED ANYWHERE.

          Every person who has signed up believes they are on a list that
          does not exist. Those addresses are gone - they were never captured,
          so they cannot be recovered. The boss needs to know this.

          Two things to do, in this order:
          1. Either wire the form to something real, or change the message so
             it stops claiming a record was made. Do not leave it as is.
          2. WHEN IT IS WIRED UP, THIS POLICY GOES STALE THE SAME DAY. It
             would then collect a name and an email address and send them to
             a third party, and this policy currently discloses neither the
             collection nor the recipient. Section 2 (what we store) and
             section 5 (who else sees it) both need updating, and the
             cookies/analytics verdict at the bottom of this block needs
             re-verifying. Treat the policy edit as part of that change, not
             as a follow-up.


  [ ] 10. SCRUB SPENT DRAFTS. Today, InvoiceDraft and RecordDraft rows are
          kept forever with their contents intact. A RecordDraft of
          kind="customer" holds a third party's name, email, phone and
          address; an InvoiceDraft holds a customer name and the line items.
          Once a draft is confirmed, cancelled, or past expires_at, that
          content is no longer needed for anything.
          APP 11.2 requires personal information to be destroyed or
          de-identified once it is no longer needed for the purpose it was
          collected for. A spent draft is exactly that, and the person whose
          details are in a RecordDraft is not our user and cannot ask us to
          delete them because they do not know we have them.

          THE FIX
          Extend purge_chat_history (core/management/commands/) so that, in
          the same daily run, it also scrubs the CONTENT of spent drafts:

            for InvoiceDraft and RecordDraft where
                status in (confirmed, cancelled) OR expires_at < now:
              clear  payload, summary, lines, qb_customer_name, qb_customer_id
              keep   id, customer, kind, status, timestamps

          Scrub the fields, keep the row. The row is the audit trail - it
          records that a draft existed and what became of it - and it carries
          no personal information once the content fields are empty. Deleting
          rows outright would break the confirmed-invoice link
          (qb_invoice_id / qb_doc_number) that ties a draft to what was
          actually created in QuickBooks.

          Decide the window: same 365 days as messages, or shorter. A spent
          draft has no ongoing use, so shorter is defensible.

          WHAT THIS UNBLOCKS
          Section 7 currently has to say draft cards are "kept indefinitely".
          Once this ships, that paragraph and the second qualification in
          section 3 can both be rewritten to state a bounded window. Update
          them in the same change - do not let the policy keep describing a
          behaviour that is no longer true.
```

## SITE FIX - its own change, its own test. Not part of the legal page.

```text
  [ ] 13. THE STICKY HEADER DOES NOT STICK, SITE-WIDE.
          styles.css:45  .page-shell { overflow: hidden; }
          styles.css:49  .site-header { position: sticky; top: 0; z-index: 50; }

          An ancestor with overflow:hidden becomes the containing block for
          sticky descendants, so .site-header sticks to .page-shell rather
          than to the viewport - which, since .page-shell is the full height
          of the document, means it never appears to stick at all. It fails
          silently: no error, no warning, and the CSS reads as though it
          works.

          The likely fix is overflow-x: clip on .page-shell instead of
          overflow: hidden - clip does not create a scroll container, so
          sticky survives. It is NOT a free swap:
            - overflow-x:clip has a Safari floor (Safari 16+). Older iOS
              would lose the horizontal-overflow containment that
              overflow:hidden is presumably there to provide.
            - whatever is overflowing horizontally needs finding first. If
              nothing is, the property can simply go.

          DELIBERATELY NOT DONE HERE. Shipping a layout change to every page
          in the same commit as a new legal page means that if something looks
          wrong afterwards, you cannot tell which caused it. The homepage is
          an approved design; this needs its own change and its own pass on
          real Safari, not just headless Chrome.

          Until it is fixed, legal.css does not use position:sticky for the
          table of contents - it would be dead CSS. When this is fixed,
          revisit .legal-toc and decide whether a sticky TOC is wanted.
```

### Related — the note that was in `legal.css`

Moved verbatim out of the `legal.css` header block on 2 Sep 2026. It sat in a
comment in a stylesheet served publicly at <https://tallyvoice.ai/legal.css>.

Two reasons it moved. It is a deliberate-omission note of the same kind as the
two comments taken off the pages in the same change. And its "See TODO item 13"
citation had come to dangle: item 13 is the entry directly above this one, and it
now lives here, not in any HTML page. A claim kept in the wrong file rots.

The rest of the `legal.css` header block — the palette, type, font, breakpoint
and added-class notes — was left in place, along with the section dividers and
the flex-layout rationale. Those are ordinary things for a stylesheet to say.

**Consequence to know about:** `legal.css` no longer explains why `.legal-toc` is
not sticky. If item 13 is fixed, or if someone adds `position: sticky` back to
`.legal-toc` without reading this file, it will silently do nothing.

```text
 *   STICKY TOC  deliberately NOT sticky. .page-shell sets overflow:hidden,
 *               which makes it the containing block for sticky descendants,
 *               so position:sticky silently does nothing inside it. See TODO
 *               item 13 — fixing that is a global change and does not belong
 *               in the same commit as a new legal page.
```

## NOT BLOCKING - verified, no action needed

```text
  [x] Backups (section 9) - CONFIRMED by the client 30 Aug 2026 in the
      DigitalOcean panel: automated backups are enabled on the production
      droplet, taken weekly on Sunday between 8PM and 12AM UTC, each one
      scheduled for deletion after 28 days. Section 9's "backed up weekly,
      and those backups are destroyed on a 28-day schedule" is accurate as
      written. Re-verify if the backup policy changes.


  [x] Cookies / analytics - verified 1 Sep 2026 across tallyvoice.ai as it
      stands today (index.html, privacy/index.html, styles.css, legal.css,
      script.js).
      The site sets no cookies, uses no localStorage or sessionStorage, loads
      no external fonts, scripts, CDNs or analytics, and makes no third-party
      requests. No cookie or tracking disclosure is owed.

      THIS VERDICT IS CONDITIONAL. It stops being true the moment any of the
      following lands, and each of them silently creates a disclosure
      obligation:
        - the early-access form is wired to anything real (see item 12);
        - an analytics or heatmap tag is added;
        - a font, icon set or script is loaded from a CDN;
        - an embed goes in (video, map, chat widget, booking iframe).
      Re-verify on any of those and update this policy before shipping it.
      Do not carry this verdict forward on trust - re-run the check.
```

---

## Verification record — entity and ABN

**Not an open item.** This is a settled verification record, kept because it
names the source and the date the entity and ABN were checked against.

Moved verbatim out of `privacy/index.html` on 2 Sep 2026, where it sat as an HTML comment
above section 1 and therefore shipped to production. The entity name and the ABN
are in the visible text of the page, so nothing was lost from it. The line that
had to come off the page is the GST note: a record of a deliberate omission,
which is exactly the kind of internal reasoning that should not be public.

```text
            <!-- Entity and ABN confirmed 30 Aug 2026 against ABN Lookup:
                 INFOLABS PTY LTD, ABN 61 615 110 346, Australian Private Company,
                 active since 30 Sep 2016, main business location QLD.
                 ABN checksum verified. NOT registered for GST - deliberately not
                 mentioned in the policy, it is not a privacy matter. -->
```
