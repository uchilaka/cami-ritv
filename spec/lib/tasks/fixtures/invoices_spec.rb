# frozen_string_literal: true

require 'rails_helper'

load_lib_script 'tasks/fixtures/invoices', ext: 'thor'

RSpec.describe Fixtures::Invoices, devtools: true do
  let!(:fixtures) do
    # rubocop:disable Lint/SymbolConversion
    {
      'items' => [
        {
          'id': random_invoice_vendor_record_id,
          'status': 'PAID',
          'detail': {
            'currency_code': 'USD',
            'note': "Thank you for your business! Looking forward to collaborating with you as your Startup begins it's journey \\",
            'invoice_number': random_invoice_number(year: 2019),
            'invoice_date': '2019-06-14',
            'payment_term': {
              'due_date': '2019-06-14'
            },
            'viewed_by_recipient': false,
            'group_draft': false,
            'metadata': {
              'create_time': '2019-06-14T10:23:26Z'
            }
          },
          'invoicer': {
            'email_address': 'filiberto@funk.test'
          },
          'primary_recipients': [
            {
              'billing_info': {
                'business_name': 'Parker',
                'name': {
                  'given_name': 'Dylan',
                  'surname': 'Azariah',
                  'full_name': 'Onyx'
                },
                'email_address': 'rossie@beer-friesen.example'
              }
            }
          ],
          'amount': {
            'currency_code': 'USD',
            'value': '200.00'
          },
          'due_amount': {
            'currency_code': 'USD',
            'value': '0.00'
          },
          'payments': {
            'paid_amount': {
              'currency_code': 'USD',
              'value': '200.00'
            }
          },
          'links': [
            {
              'href': 'https://api.paypal.com/v2/invoicing/invoices/INV2-9E3C-DPSK-2H9Y-4VA6',
              'rel': 'self',
              'method': 'GET'
            }
          ],
          'unilateral': false
        },
        {
          'id': random_invoice_vendor_record_id,
          'status': 'CANCELLED',
          'detail': {
            'currency_code': 'USD',
            'note': "Hey Team! \r\n\r\nGoogle increased the price of G-Suite Basic from $5 / User / Mo. to $6 / User / Mo. starting May 2019\r\n\r\nThis is a pro-rated invoice to cover the difference from your paid invoice #2019-INV0012\r\n\r\nQuestions? Let us know at support@larcity.com",
            'invoice_number': random_invoice_number(year: 2019),
            'invoice_date': '2019-05-01',
            'payment_term': {
              'due_date': '2019-05-01'
            },
            'viewed_by_recipient': true,
            'group_draft': false,
            'metadata': {
              'create_time': '2019-06-14T10:12:43Z'
            }
          },
          'invoicer': {
            'email_address': 'lashawna_parisian@moore.test'
          },
          'primary_recipients': [
            {
              'billing_info': {
                'business_name': 'Sawyer',
                'name': {
                  'given_name': 'Armani',
                  'surname': 'Sawyer',
                  'full_name': 'Briar'
                },
                'email_address': 'logan@becker.example'
              }
            }
          ],
          'amount': {
            'currency_code': 'USD',
            'value': '17.20'
          },
          'due_amount': {
            'currency_code': 'USD',
            'value': '17.20'
          },
          'links': [
            {
              'href': 'https://api.paypal.com/v2/invoicing/invoices/INV2-FHP4-DTGD-XFH7-5WBU',
              'rel': 'self',
              'method': 'GET'
            }
          ],
          'unilateral': false
        },
        {
          'id': random_invoice_vendor_record_id,
          'status': 'CANCELLED',
          'detail': {
            'currency_code': 'USD',
            'note': "Hey Team - \r\n\r\nI've setup this monthly invoice for our G-Suite billing. The invoice is setup to allow partial payment so that we don't need an individual invoice for each user. \r\n\r\nIf you would like to pay for just your (1x) account, please enter the unit price displayed on the invoice as your payment amount. The invoice will stay open until the entire amount due is met by the team. \r\n\r\nI've included everyone setup on our Quup G-Suite service on the invoice. Let me know if you have any questions. \r\n\r\nCheers!",
            'invoice_number': random_invoice_number(year: 2019),
            'invoice_date': '2019-06-01',
            'payment_term': {
              'due_date': '2019-06-01'
            },
            'viewed_by_recipient': false,
            'group_draft': false,
            'metadata': {
              'create_time': '2019-06-01T11:00:59Z'
            }
          },
          'invoicer': {
            'email_address': 'kari@kub-lynch.test'
          },
          'primary_recipients': [
            {
              'billing_info': {
                'business_name': 'Tatum',
                'email_address': 'wilber.nitzsche@rogahn.example'
              }
            }
          ],
          'amount': {
            'currency_code': 'USD',
            'value': '10.00'
          },
          'due_amount': {
            'currency_code': 'USD',
            'value': '10.00'
          },
          'links': [
            {
              'href': 'https://api.paypal.com/v2/invoicing/invoices/INV2-HRJG-TB9Z-8CZW-9SFW',
              'rel': 'self',
              'method': 'GET'
            }
          ],
          'recurring_Id': 'RI-56D78462GL467282P',
          'unilateral': false
        },
        {
          'id': random_invoice_vendor_record_id,
          'status': 'CANCELLED',
          'detail': {
            'currency_code': 'USD',
            'note': "Hey Team - \r\n\r\nI've setup this monthly invoice for our G-Suite billing. The invoice is setup to allow partial payment so that we don't need an individual invoice for each user. \r\n\r\nIf you would like to pay for just your (1x) account, please enter the unit price displayed on the invoice as your payment amount. The invoice will stay open until the entire amount due is met by the team. \r\n\r\nI've included everyone setup on our Quup G-Suite service on the invoice. Let me know if you have any questions. \r\n\r\nCheers!",
            'invoice_number': random_invoice_number(year: 2019),
            'invoice_date': '2019-05-01',
            'payment_term': {
              'due_date': '2019-05-01'
            },
            'viewed_by_recipient': false,
            'group_draft': false,
            'metadata': {
              'create_time': '2019-05-01T11:01:22Z'
            }
          },
          'invoicer': {
            'email_address': 'cody.denesik@morissette.test'
          },
          'primary_recipients': [
            {
              'billing_info': {
                'business_name': 'Phoenix',
                'email_address': 'landon_abbott@williamson-smith.example'
              }
            }
          ],
          'amount': {
            'currency_code': 'USD',
            'value': '10.00'
          },
          'due_amount': {
            'currency_code': 'USD',
            'value': '10.00'
          },
          'links': [
            {
              'href': 'https://api.paypal.com/v2/invoicing/invoices/INV2-MFMZ-A99Q-TLZT-X862',
              'rel': 'self',
              'method': 'GET'
            }
          ],
          'recurring_Id': 'RI-56D78462GL467282P',
          'unilateral': false
        },
        {
          'id': random_invoice_vendor_record_id,
          'status': 'CANCELLED',
          'detail': {
            'currency_code': 'USD',
            'note': "Hey Team - \r\n\r\nI've setup this monthly invoice for our G-Suite billing. The invoice is setup to allow partial payment so that we don't need an individual invoice for each user. \r\n\r\nIf you would like to pay for just your (1x) account, please enter the unit price displayed on the invoice as your payment amount. The invoice will stay open until the entire amount due is met by the team. \r\n\r\nI've included everyone setup on our Quup G-Suite service on the invoice. Let me know if you have any questions. \r\n\r\nCheers!",
            'invoice_number': random_invoice_number(year: 2019),
            'invoice_date': '2019-04-01',
            'payment_term': {
              'due_date': '2019-04-01'
            },
            'viewed_by_recipient': false,
            'group_draft': false,
            'metadata': {
              'create_time': '2019-04-01T11:00:56Z'
            }
          },
          'invoicer': {
            'email_address': 'warren@hermann.test'
          },
          'primary_recipients': [
            {
              'billing_info': {
                'business_name': 'Robin',
                'email_address': 'brigitte@murazik-graham.example'
              }
            }
          ],
          'amount': {
            'currency_code': 'USD',
            'value': '10.00'
          },
          'due_amount': {
            'currency_code': 'USD',
            'value': '10.00'
          },
          'links': [
            {
              'href': 'https://api.paypal.com/v2/invoicing/invoices/INV2-ECB7-2YMP-GVPT-Q7BH',
              'rel': 'self',
              'method': 'GET'
            }
          ],
          'recurring_Id': 'RI-56D78462GL467282P',
          'unilateral': false
        },
        {
          'id': random_invoice_vendor_record_id,
          'status': 'PAID',
          'detail': {
            'currency_code': 'USD',
            'note': "Hi Chuji!\r\n\r\nYour current registration for 360supplychain.com is good until 09/2019.",
            'invoice_number': random_invoice_number(year: 2019),
            'invoice_date': '2019-03-09',
            'payment_term': {
              'due_date': '2019-03-09'
            },
            'viewed_by_recipient': false,
            'group_draft': false,
            'metadata': {
              'create_time': '2019-03-09T12:00:39Z'
            }
          },
          'invoicer': {
            'email_address': 'cody@kilback-heidenreich.example'
          },
          'primary_recipients': [
            {
              'billing_info': {
                'business_name': 'Robin',
                'name': {
                  'given_name': 'Alexis',
                  'surname': 'Indigo',
                  'full_name': 'Avery'
                },
                'email_address': 'laree@murphy.test'
              }
            }
          ],
          'amount': {
            'currency_code': 'USD',
            'value': '12.00'
          },
          'due_amount': {
            'currency_code': 'USD',
            'value': '0.00'
          },
          'payments': {
            'paid_amount': {
              'currency_code': 'USD',
              'value': '12.00'
            }
          },
          'links': [
            {
              'href': 'https://api.paypal.com/v2/invoicing/invoices/INV2-HP54-4DUA-ZZ4X-AKNK',
              'rel': 'self',
              'method': 'GET'
            }
          ],
          'recurring_Id': 'RI-42C626788M529081F',
          'unilateral': false
        },
        {
          'id': random_invoice_vendor_record_id,
          'status': 'PAID',
          'detail': {
            'currency_code': 'USD',
            'note': "Hi Delali - \r\n\r\nI've confirmed the domain was renewed successfully! Soon as the invoice is actioned, I'll be updating the domain to give you full control of it through https://domains.google. \r\n\r\nHappy Holidays!\r\n\r\nUche",
            'invoice_number': random_invoice_number(year: 2018),
            'invoice_date': '2018-12-16',
            'payment_term': {
              'due_date': '2018-12-16'
            },
            'viewed_by_recipient': false,
            'group_draft': false,
            'metadata': {
              'create_time': '2018-12-16T23:17:02Z'
            }
          },
          'invoicer': {
            'email_address': 'ailene.veum@ratke.example'
          },
          'primary_recipients': [
            {
              'billing_info': {
                'name': {
                  'given_name': 'Greer',
                  'surname': 'Cameron',
                  'full_name': 'Phoenix'
                },
                'email_address': 'mohammad_ratke@keebler.test'
              }
            }
          ],
          'amount': {
            'currency_code': 'USD',
            'value': '12.00'
          },
          'due_amount': {
            'currency_code': 'USD',
            'value': '0.00'
          },
          'payments': {
            'paid_amount': {
              'currency_code': 'USD',
              'value': '12.00'
            }
          },
          'links': [
            {
              'href': 'https://api.paypal.com/v2/invoicing/invoices/INV2-J7PA-R9MM-DKCC-7NB4',
              'rel': 'self',
              'method': 'GET'
            }
          ],
          'unilateral': false
        },
        {
          'id': random_invoice_vendor_record_id,
          'status': 'PAID',
          'detail': {
            'currency_code': 'USD',
            'note': "Hi Sammy! \r\n\r\nLet me know if you would like this domain name renewed. If not, it is set to lapse by December 24, 2018 and no action is required. \r\n\r\nCheers",
            'invoice_number': random_invoice_number(year: 2018),
            'invoice_date': '2018-12-16',
            'payment_term': {
              'due_date': '2018-12-16'
            },
            'viewed_by_recipient': false,
            'group_draft': false,
            'metadata': {
              'create_time': '2018-12-16T21:13:08Z'
            }
          },
          'invoicer': {
            'email_address': 'rene@oreilly-dickens.test'
          },
          'primary_recipients': [
            {
              'billing_info': {
                'business_name': 'Haven',
                'name': {
                  'given_name': 'Emerson',
                  'surname': 'Ryan',
                  'full_name': 'River'
                },
                'email_address': 'denis_price@dibbert.test'
              }
            }
          ],
          'amount': {
            'currency_code': 'USD',
            'value': '12.00'
          },
          'due_amount': {
            'currency_code': 'USD',
            'value': '0.00'
          },
          'payments': {
            'paid_amount': {
              'currency_code': 'USD',
              'value': '12.00'
            }
          },
          'links': [
            {
              'href': 'https://api.paypal.com/v2/invoicing/invoices/INV2-SXVE-DE6X-N4F6-V5Z7',
              'rel': 'self',
              'method': 'GET'
            }
          ],
          'recurring_Id': 'RI-71W40404Y76836012',
          'unilateral': false
        },
        {
          'id': random_invoice_vendor_record_id,
          'status': 'PAID',
          'detail': {
            'currency_code': 'USD',
            'note': "Please let us know if you have any questions @ support@larcity.com. \r\n\r\nLooking forward to making your online business experiences even better with custom email raised to the power of G-Suite.",
            'invoice_number': random_invoice_number(year: 2019),
            'invoice_date': '2019-01-04',
            'payment_term': {
              'due_date': '2019-01-04'
            },
            'viewed_by_recipient': false,
            'group_draft': false,
            'metadata': {
              'create_time': '2018-12-03T04:07:55Z'
            }
          },
          'invoicer': {
            'email_address': 'berta@gutmann-shields.test'
          },
          'primary_recipients': [
            {
              'billing_info': {
                'business_name': 'Gray',
                'email_address': 'elijah@prosacco-koepp.test'
              }
            }
          ],
          'amount': {
            'currency_code': 'USD',
            'value': '120.00'
          },
          'due_amount': {
            'currency_code': 'USD',
            'value': '0.00'
          },
          'payments': {
            'paid_amount': {
              'currency_code': 'USD',
              'value': '120.00'
            }
          },
          'links': [
            {
              'href': 'https://api.paypal.com/v2/invoicing/invoices/INV2-AET3-SRKH-REPK-B8MT',
              'rel': 'self',
              'method': 'GET'
            }
          ],
          'unilateral': false
        },
        {
          'id': random_invoice_vendor_record_id,
          'status': 'PAID',
          'detail': {
            'currency_code': 'USD',
            'note': 'Hi Chuji - Let me know your GMail address so I can add you as an admin for the domain as discussed. I can prepare an invoice for GMail for Business or any other services you decide on when you are ready. For now, this takes care of the domain parking with Google. Cheers!',
            'invoice_number': random_invoice_number(year: 2018),
            'invoice_date': '2018-01-19',
            'payment_term': {
              'due_date': '2018-01-19'
            },
            'viewed_by_recipient': false,
            'group_draft': false,
            'metadata': {
              'create_time': '2018-01-20T02:50:30Z'
            }
          },
          'invoicer': {
            'email_address': 'wes_vonrueden@jacobi-rice.example'
          },
          'primary_recipients': [
            {
              'billing_info': {
                'email_address': 'phil_gusikowski@kessler.example'
              }
            }
          ],
          'amount': {
            'currency_code': 'USD',
            'value': '12.00'
          },
          'due_amount': {
            'currency_code': 'USD',
            'value': '0.00'
          },
          'payments': {
            'paid_amount': {
              'currency_code': 'USD',
              'value': '12.00'
            }
          },
          'links': [
            {
              'href': 'https://api.paypal.com/v2/invoicing/invoices/INV2-JCL6-CFC5-T3ZT-G8S8',
              'rel': 'self',
              'method': 'GET'
            }
          ],
          'unilateral': false
        },
      ],
      'links' => [
        {
          'href': 'https://api.paypal.com/v2/invoicing/invoices?page=2&page_size=10&total_required=false',
          'rel': 'self',
          'method': 'GET'
        },
        {
          'href': 'https://api.paypal.com/v2/invoicing/invoices?page=1&page_size=10&total_required=false',
          'rel': 'prev',
          'method': 'GET'
        }
      ]
    }
    # rubocop:enable Lint/SymbolConversion
  end

  before { allow(YAML).to receive(:load).and_return(fixtures) }

  describe '#load' do
    subject { described_class.new.invoke(:load, []) }

    it 'loads the fixtures' do
      expect { subject }.to change(Invoice, :count).by(10).and \
        change(Account, :count).by(10)
    end

    context 'when some fixtures have already been loaded' do
      let(:invoices_to_load) do
        [
          PayPal::InvoiceSerializer.new(fixtures['items'][0].with_indifferent_access).serializable_hash,
          PayPal::InvoiceSerializer.new(fixtures['items'][1].with_indifferent_access).serializable_hash,
        ]
      end

      before do
        invoices_to_load.each do |invoice_data|
          Invoice.create!(invoice_data)
        end
      end

      it 'loads only the new fixtures' do
        expect { subject }.to change(Invoice, :count).by(8).and \
          change(Account, :count).by(8)
      end
    end
  end
end
