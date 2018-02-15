<% @ Control Language="C#" ClassName="EWayExt" Debug="true" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Web.Script.Serialization" %>
<%@ Import Namespace="System.ComponentModel" %>
<%@ Import Namespace="System.Diagnostics" %>
<%@ Import Namespace="System.Reflection" %>
<%@ Import Namespace="System.Resources" %>
<%@ Import Namespace="Dashing.EWayClient" %>
<%@ Import Namespace="Dashing.EWayClient.EWay" %>
<%@ Import Namespace="uStore.Common.BLL.PricingModels.DefaultPricingModel"%>


<script runat="server" language="c#">

    #region Helper Properties and Methods
    private OrderPrice _orderPrice;
    private uStore.Common.BLL.Order _orderDetails;
    public string ClearingDisplayName { get; set; }
    public string PaymentEndpoint { get; set; }
    public string UserName { get; set; }
    public string Password { get; set; }
    private const string RequestAccessCodeLogSP = "AddEWayAccessCodeRequestLog";
    private const string PaymentResultLogSP = "AddEWayPaymentResultLog";
    private const string EventLogSource = "EWay";
    public bool IsCheckoutPage
    {
        get
        {
            if( Page.Request.FilePath.Contains("/uStore/CheckoutPaymentSubmission.aspx"))
            {
                return true;
            }

            return false;

        }
    }

    private bool IsEWayClearing()
    {
        bool result = false;
        string clearing = "";
        foreach (string key in Request.Form.Keys)
        {
            if (key.StartsWith("ctl00$cphMainContent$ctlClearingUserData") && key.EndsWith("$txtCostCenter"))
            {
                clearing = Request[key];
                break;
            }
        }

        if (clearing == ClearingDisplayName)
        {
            result = true;
        }

        return result;
    }

    public bool IsCheckoutCompletePage
    {
        get
        {
            if( Page.Request.FilePath == "/uStore/CheckOutComplete.aspx" )
            {
                return true;
            }
            return false;

        }
    }


    public bool IsCartPage
    {
        get
        {
            if( Page.Request.Url.AbsolutePath.Contains("/uStore/Cart"))
            {
                return true;
            }

            return false;

        }
    }

    public List<Object[]> DBQuery(String sqlQuery)
    {
        SqlConnection connection = new SqlConnection("server=556627-SQL1;database=uStore;Pooling=True;uid=sa;pwd=4P3Jh7MZP4Gj;");
        SqlCommand cmd = new SqlCommand();
        SqlDataReader reader;
        cmd.CommandText = sqlQuery;
        cmd.CommandType = CommandType.Text;
        cmd.Connection = connection;
        connection.Open();
        reader = cmd.ExecuteReader();
        List<Object[]>  rows = new List<Object[]>();
        while (reader.Read())
        {
            Object[] values = new Object[reader.FieldCount];
            int fieldCount = reader.GetValues(values);
            rows.Add(values);
        }
        connection.Close();
        return rows;
    }


    public int AddAccessRequestLog( string encryptedOrderId,string accessCode ,string errors,DateTime requestTime,int totalAmount)
    {
        SqlConnection connection = new SqlConnection("server=556627-SQL1;database=GLD-Xmpie-EXT;Pooling=True;uid=sa;pwd=4P3Jh7MZP4Gj;");
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = RequestAccessCodeLogSP;
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Parameters.Add("@EncryptedOrderID",SqlDbType.VarChar,500).Value = encryptedOrderId;
        cmd.Parameters.Add("@AccessCode",SqlDbType.VarChar,500).Value = accessCode;
        cmd.Parameters.Add("@Errors",SqlDbType.VarChar,1024).Value = string.IsNullOrWhiteSpace(errors)?"":errors;
        cmd.Parameters.Add("@RequestTime",SqlDbType.DateTime).Value = requestTime;
        cmd.Parameters.Add("@TotalAmount",SqlDbType.Int).Value = totalAmount;
        cmd.Connection = connection;
        connection.Open();
        var result = cmd.ExecuteNonQuery();
        connection.Close();
        return result;
    }

    public int AddPaymentResultLog(string accessCode, bool transactionStatus, string responseMessage, string encryptedOrderId, string errors, int totalAmount, DateTime responseTime, string responseCode="", string responseDisplayMessage="")
    {
        SqlConnection connection = new SqlConnection("server=556627-SQL1;database=GLD-Xmpie-EXT;Pooling=True;uid=sa;pwd=4P3Jh7MZP4Gj;");
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = PaymentResultLogSP;
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Parameters.Add("@AccessCode",SqlDbType.VarChar,500).Value=accessCode;
        cmd.Parameters.Add("@TransactionStatus",SqlDbType.TinyInt).Value = transactionStatus;
        cmd.Parameters.Add("@ResponseMessage",SqlDbType.VarChar,1024).Value=responseMessage;
        cmd.Parameters.Add("@EncryptedOrderID",SqlDbType.VarChar,500).Value=encryptedOrderId;
        cmd.Parameters.Add("@Errors",SqlDbType.VarChar,1024).Value=string.IsNullOrWhiteSpace(errors)?"":errors;
        cmd.Parameters.Add("@ResponseTime",SqlDbType.DateTime).Value=responseTime;
        cmd.Parameters.Add("@TotalAmount",SqlDbType.Int).Value = totalAmount;
        cmd.Parameters.Add("@ResponseCode",SqlDbType.VarChar,1024).Value=string.IsNullOrWhiteSpace(responseCode)?"":responseCode;
        cmd.Parameters.Add("@ResponseDisplayMessage",SqlDbType.VarChar,1024).Value=string.IsNullOrWhiteSpace(responseDisplayMessage)?"":responseDisplayMessage;

        cmd.Connection = connection;
        connection.Open();
        var result = cmd.ExecuteNonQuery();
        connection.Close();
        return result;
    }

    bool error = false;
    String errorMsg = "";

    private int GetDashingTotalAmount()
    {
        string totalAmountFullString = Request.Form["dashingtotalpayment"];

        var doubleArray = Regex.Split(totalAmountFullString, @"[^0-9\.]+")
            .Where(c => c != "." && c.Trim() != "");

        var totalAmountString = doubleArray.FirstOrDefault();
        //eWay expects the total amount in cents
        int totalAmountInt = (int)(decimal.Parse(totalAmountString) * 100);
        return totalAmountInt;
    }

    private decimal GetDashingTotalTax()
    {
        string totalTaxFullString = Request.Form["dashingtotaltax"];

        var doubleArray = Regex.Split(totalTaxFullString, @"[^0-9\.]+")
            .Where(c => c != "." && c.Trim() != "");

        var totalTaxString = doubleArray.FirstOrDefault();
        decimal totalTaxInt = decimal.Parse(totalTaxString);
        return totalTaxInt;
    }

    private void CreateSharedPayment()
    {

        EWayPaymentProxy client = new EWayPaymentProxy(PaymentEndpoint, UserName, Password);
        var Order = GetCurrentOrder();
        int totalAmountInt = GetDashingTotalAmount();
        //totalAmountInt = 10051;
        uStoreAPI.User currentUser = uStoreAPI.User.GetUser(uStore.Common.BLL.CustomerInfo.Current.UserID);
        CreateAccessCodeSharedRequest request = new CreateAccessCodeSharedRequest
        {
            Customer = new Customer()
            {
                Reference = Order.EncryptedOrderID.ToString(),
                FirstName = currentUser.FirstName,
                LastName = currentUser.LastName,
                Street1 = Order.Bill_Add,
                Street2 = Order.Bill_Add2,
                City = Order.Bill_City,
                State = Order.Bill_StateName,
                PostalCode = Order.Bill_Zip,
                Country = "au",
                Email = Order.Bill_Email,
                Phone = Order.Bill_Phone,
                Mobile = Order.Bill_Phone
            },
            Payment = new Payment()
            {
                TotalAmount = totalAmountInt,
                InvoiceNumber = Order.EncryptedOrderID.ToString(),
                InvoiceDescription = Order.EncryptedOrderID.ToString(),
                InvoiceReference = Order.EncryptedOrderID.ToString(),
                CurrencyCode = "AUD"
            },
            RedirectUrl = string.Format("{0}://{1}{2}/{3}?qs={4}&isewayclearing=true", Request.Url.Scheme, Request.Url.Authority,Request.ApplicationPath,"CheckOutComplete.aspx",Request["qs"]),
            CancelUrl = string.Format("{0}://{1}{2}/{3}?qs={4}&cancelled=true&orderId={5}", Request.Url.Scheme, Request.Url.Authority, Request.ApplicationPath, "CheckoutPaymentSubmission.aspx", Request["qs"], Order.EncryptedOrderID.ToString()),
            TransactionType = TransactionTypes.Purchase,
            Method = Method.ProcessPayment,
            CustomerReadOnly = true,
            VerifyCustomerEmail = false,
            VerifyCustomerPhone = false,
            LogoUrl = "https://dashinggroup.com.au/wp-content/themes/dashing/assets/images/dashing_logo.svg",
            //HeaderText = "Dashing Group",
            Language = "EN",
            CustomView = CustomView.Bootstrap,

        };
        try
        {

            var accessCodeSharedResponse = client.CreateAccessCodeShared(request);
            try
            {
                AddAccessRequestLog(Order.EncryptedOrderID.ToString(), accessCodeSharedResponse.AccessCode, accessCodeSharedResponse.Errors, DateTime.Now, totalAmountInt);

            }
            catch (Exception e)
            {

                if (!EventLog.SourceExists(EventLogSource))
                {
                    EventLog.CreateEventSource(EventLogSource, "Application");
                }
                EventLog.WriteEntry(EventLogSource, e.Message + " AccessCode:" + accessCodeSharedResponse.AccessCode);
            }
            //Redirect to responsive shared page if all good
            if (string.IsNullOrWhiteSpace(accessCodeSharedResponse.Errors) && !string.IsNullOrWhiteSpace(accessCodeSharedResponse.SharedPaymentUrl))
            {
                Response.Redirect(accessCodeSharedResponse.SharedPaymentUrl, true);
            }
            else
            {
                Session["Failed"] = true;
                Session["ErrorMessage"] = "Error in creating eway access Code: " + accessCodeSharedResponse.Errors;
                Response.Redirect("Cart");
            }

        }
        catch (System.Threading.ThreadAbortException redirectException)
        {
            //Do nothing as we are doing the redirection intentionally to the eway page
        }
        catch (Exception e)
        {
            //If there is a problem making the api call, log the error
            try
            {

                AddAccessRequestLog(Order.EncryptedOrderID.ToString(), "", "Communication error:" + e.Message + ": " + e.GetType(), DateTime.Now, totalAmountInt);
            }
            catch (Exception ex)
            {
                if (!EventLog.SourceExists(EventLogSource))
                {
                    EventLog.CreateEventSource(EventLogSource, "Application");
                }
                EventLog.WriteEntry(EventLogSource, ex.Message);
            }
            finally
            {
                Session["Failed"] = true;
                Session["ErrorMessage"] = e.Message;
                Response.Redirect("Cart");
            }

        }

    }

    private void GetPaymentDetails(string accessCode)
    {
        var Order = GetCurrentOrder();
        GetAccessCodeResultResponse result = null;
        string displayMessage = "";
        try
        {
            EWayPaymentProxy client = new EWayPaymentProxy(PaymentEndpoint, UserName, Password);
            result = client.GetResult(accessCode);
        }
        catch (Exception e)
        {
            //Communication error
            error = true;
            errorMsg = "Error communicating with the payment gateway";
            string logMessage = "Communication error:" + e.Message;
            if (result != null)
            {
                errorMsg += ", Response Code:" + result.ResponseCode;
                logMessage += ", Response Code:" + result.ResponseCode;
            }
            try
            {
                AddPaymentResultLog(accessCode, false, "", Order.EncryptedOrderID.ToString(),logMessage, (int) (Order.TotalPrice * 100), DateTime.Now);
            }
            catch (Exception ex)
            {
                if (!EventLog.SourceExists(EventLogSource))
                {
                    EventLog.CreateEventSource(EventLogSource, "Application");
                }
                EventLog.WriteEntry(EventLogSource, ex.Message + " AccessCode:" + accessCode);
            }
        }
        string sqlGetEWayMessage = string.Format("EXEC [GLD-Xmpie-EXT].[dbo].[GetEWayMessageByCode] @Code ='{0}'",result.ResponseCode);
        List<Object[]> sqlGetEWayMessageResult = null;

        //Transaction was successful
        if (result != null && result.TransactionStatus != null && result.TransactionStatus.Value && (result.ResponseCode == "00" || result.ResponseCode == "08"))
        {

            try
            {
                sqlGetEWayMessageResult = DBQuery(sqlGetEWayMessage);
                foreach (var obj in sqlGetEWayMessageResult)
                {
                    displayMessage = ((string) obj[0]).Trim();
                }
                //Log the successful transaction result
                AddPaymentResultLog(accessCode, true, result.ResponseMessage, result.InvoiceNumber, result.Errors, result.TotalAmount.Value, DateTime.Now, result.ResponseCode, displayMessage);
            }
            catch (Exception ex)
            {
                if (!EventLog.SourceExists(EventLogSource))
                {
                    EventLog.CreateEventSource(EventLogSource, "Application");
                }
                EventLog.WriteEntry(EventLogSource, ex.Message + " AccessCode:" + accessCode);
            }

            try
            {
                var orderDetails =  uStore.Common.BLL.Order.Get(GetCurrentOrder().OrderID);
                orderDetails.FinalizeOrderAfterClearing((int) System.Web.HttpContext.Current.Session["CultureId"]);
                uStoreAPI.Order.SubmitOrder(Order.OrderID);
            }
            catch (Exception ex)
            {
                //Error submitting the order
                //AddEWayGeneralLog
                string sqlGenrealLog = string.Format("EXEC [GLD-Xmpie-EXT].[dbo].[AddEWayGeneralLog] @ErrorMessage ='Error submitting the order: {0}' , @AccessCode='{1}', @EncryptedOrderId='{2}'",ex.Message,accessCode,Order.EncryptedOrderID);
                DBQuery( sqlGenrealLog );
            }
            //on payment received toggle state to pending 1
            //List<Object[]> togglePending = this.DBQuery("EXEC [GLD-Xmpie-EXT].[dbo].[confirmUstorePayment] @ID = " + Order.OrderID);

        }
        else // Failed transaction
        {
            try
            {
                sqlGetEWayMessageResult = this.DBQuery(sqlGetEWayMessage);
                foreach (var obj in sqlGetEWayMessageResult)
                {
                    displayMessage = ((string) obj[0]).Trim();
                }
                //Log the failed transaction result
                AddPaymentResultLog(accessCode, true, result.ResponseMessage, result.InvoiceNumber, errorMsg, result.TotalAmount.Value,DateTime.Now, result.ResponseCode, displayMessage);
            }
            catch (Exception ex){
                if (!EventLog.SourceExists(EventLogSource))
                {
                    EventLog.CreateEventSource(EventLogSource,"Application");
                }
                EventLog.WriteEntry(EventLogSource, ex.Message + " AccessCode:" + accessCode);
            }

            //TODO: do any required rollback to the order statuses
            //Redirect to the cart incase of any failure
            error = true;
            errorMsg = displayMessage;
            Session["Failed"] = true;
            Session["ErrorMessage"] = displayMessage;
            Response.Redirect("Cart");


        }
    }

    private uStoreAPI.Order GetCurrentOrder()
    {
        uStoreAPI.User User = uStoreAPI.User.GetUser(uStore.Common.BLL.CustomerInfo.Current.UserID);
        int orderId = 0;
        int isApproved = 0;
        string sql = "EXEC [GLD-Xmpie-EXT].[dbo].[getLatestOrderByUser] @User = " +
                     uStore.Common.BLL.CustomerInfo.Current.UserID + ", @Store = " +
                     (int) System.Web.HttpContext.Current.Session["StoreID"];
        List<Object[]> sqlResult1 = this.DBQuery(sql);
        foreach (var obj in sqlResult1)
        {
            orderId = (int) obj[0];
        }

        uStoreAPI.Order Order =
            uStoreAPI.Order.GetOrder(orderId, (int) System.Web.HttpContext.Current.Session["CultureId"]);
        return Order;
    }

    #endregion
    //In the checkout submission page we create the payment
    private void Page_Load(object sender, EventArgs e)
    {
        string eventTarget = Request.Params["__EVENTTARGET"];
        bool isApprovalRequired = false;
        //EWayCheckout: the code that is executed on checkout page and when the ewayclearing is enabled
        if (IsCheckoutPage && IsPostBack && !string.IsNullOrEmpty(eventTarget) && eventTarget.ToLower().Contains("cphMainContentFooter$btnCheckout".ToLower()) && IsEWayClearing())
        {
            if (isApprovalRequired)
            {
                Session["EWayApprovalEnabled"] = true;
            }
            else
            {
                var wrapper = new uStore.DataLayer.DB.DBWrapper(true);
                _orderDetails =  uStore.Common.BLL.Order.Get(GetCurrentOrder().OrderID);

                this._orderDetails.DeliveryTentatives = this.GetShipments();
                _orderPrice = OrderPrice.Calculate(_orderDetails, 0,(int) System.Web.HttpContext.Current.Session["CultureId"]);

                //TODO:Change this to get it from the page
                _orderPrice.TotalTax =GetDashingTotalTax();
                _orderPrice.Total = GetDashingTotalAmount()/100M;
                int clearingConfigId = int.Parse(Request["ctl00$cphMainContent$rdlClearingConfig"]);
                _orderDetails.PaymentMethodId = clearingConfigId;
                _orderDetails.SubTotalPrice = _orderPrice.Subtotal;
                _orderDetails.ShippingCharges = _orderPrice.ShippingCharges;
                _orderDetails.TaxAmount = _orderPrice.TotalTax;
                _orderDetails.TaxDetailsXML = _orderPrice.TaxDetailsXML.OuterXml;
                _orderDetails.TotalOrderPrice = _orderPrice.Total;
                _orderDetails.Cost = _orderPrice.Cost;
                _orderDetails.ClearingStatus = 1;
                UpdateOrderProductTaxes(_orderPrice.TaxItems);
                _orderDetails.DateOrderSubmitted = new DateTime?(DateTime.Now);
                _orderDetails.UpdateCartDetails();

                uStore.Common.BLL.Delivery.Shipping.DeliveryTentative.ClearDeliveryTentatives(this._orderDetails.OrderId);
                uStore.Common.BLL.Delivery.Shipping.DeliveryTentative.AddDeliveryTentatives(this._orderDetails);

                wrapper.CommitTransaction();

                foreach (uStore.Common.BLL.Tax.TaxItem item in _orderPrice.TaxItems)
                {
                    Response.Write("item.TaxAmount: " + item.TaxAmount + "<br />");
                }

                Session["EWayApprovalEnabled"] = null;
                CreateSharedPayment();
            }

        }
        else
        {
            //TODO: write the required code to handle the approval
            //Session["EWayApprovalEnabled"] = true;
            //Response.Redirect("CheckoutPaymentSubmission.aspx?qs=" + Request["qs"], true);

        }
    }
    private List<uStore.Common.BLL.Delivery.Shipping.DeliveryTentative> GetShipments()
    {
        return (((uStore.CheckoutPaymentSubmission)this.Page).PageDataParams["OrderShipments"] as List<uStore.Common.BLL.Delivery.Shipping.DeliveryTentative>);
    }

    private void UpdateOrderProductTaxes(ICollection<uStore.Common.BLL.Tax.TaxItem> taxItemList)
    {
        foreach (uStore.Common.BLL.Tax.TaxItem item in taxItemList)
        {
            if (item.TaxAmount > 0M)
            {
                uStore.Common.BLL.OrderProductDetails.UpdateTax(item);
            }
        }
    }

</script>
<%
    //In the checkout complete we get the payment result
    if (IsCheckoutCompletePage)
    {
        try
        {
            if (Request["isewayclearing"]=="true")
            {
                if (!string.IsNullOrWhiteSpace(Request["AccessCode"]))
                {
                    GetPaymentDetails(Request["AccessCode"]);
                }
            }

        }
        catch (Exception e)
        {
            Response.Write(e.Message);
        }

    }



    //Below code handles the client side UI handling and error display
%>


<% if(IsCheckoutPage) { %>
    <script>
        var $Msglabel = $("<label>").text('When you click Submit Order, you will be redirected to eWay to complete your payment details. Please do not leave the site or close your browser before you are redirected from eWay back to the store.');

        $(document).ready(function () {
            $('<input>').attr({
                type: 'hidden',
                id: 'dashingtotalpayment',
                name: 'dashingtotalpayment'
            }).appendTo('form');

            $('<input>').attr({
                type: 'hidden',
                id: 'dashingtotaltax',
                name: 'dashingtotaltax'
            }).appendTo('form');

            

            $('#dashingtotalpayment').val($('#ctl00_cphMainContent_ucOrderPrice_lblTotal').text());
            $('#dashingtotaltax').val($('#ctl00_cphMainContent_ucOrderPrice_lblTaxAmount').text());

            var $cnt = $('#ctl00_cphMainContent_rdlClearingConfig tr').length;
            //user chooses to pay via eWay and the user has multiple clearing method options
            if ($("label:contains('<%=this.ClearingDisplayName%>')").prev("input").is(':checked')) {
                $("span:contains('Cost Center:')").next("input").val("<%=this.ClearingDisplayName%>");
                $("span:contains('Cost Center:')").parent().css("display", "none");
                $('#ctl00_cphMainContent_trClearingMethods').next('tr').append($Msglabel);

            }
            //if only eWay clearing method is set
            else if ((($cnt == 0) && ("label:contains('<%=this.ClearingDisplayName%>')"))) {
                $("span:contains('Cost Center:')").next("input").val("<%=this.ClearingDisplayName%>");
                $("span:contains('Cost Center:')").parent().css("display", "none");
                $('#ctl00_cphMainContent_HideShippingType').prev('tr').html("<td><label>When you click Submit Order, you will be redirected to eWay to complete your payment details. Please do not leave the site or close your browser before you are redirected from eWay back to the store.</label></td>");

            }

            <% if (!string.IsNullOrEmpty(Request["cancelled"]) && !IsPostBack){ %>

                swal("Transaction Cancelled", "Transaction was cancelled by the user", "error");
                    
               <% }%>


        });
    </script>
<% } %>


<% if(IsCheckoutCompletePage) { %>
    <script>
        $(document).ready(function () {
            var error = "<%=error%>";
            if (error == "True") {
                swal("Error", error, "error");
            }
        });
    </script>
<% } %>

 
<%

   if (IsCartPage && Session["Failed"] != null && Session["ErrorMessage"] != null && !IsPostBack) { %>
    <script>
        $(document).ready(function () {
            swal("Transaction failed", "<%= Session["ErrorMessage"].ToString() %>", "error");
           
        });
    </script>
<% 

        Session["Failed"] = null;
        Session["ErrorMessage"] = null;

    }
%>