using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Linq;
using GrowFlow.Web.Attributes;
using System.Web.Mvc;
using GrowFlow.Api.Compliance.Service;
using GrowFlow.Model.Inventory;
using GrowFlow.Model.Persistance;
using GrowFlow.Web.DTO.Inventory;

namespace GrowFlow.Web.Controllers
{
    [AuthorizeUser]
    public class InventoryController : GrowFlowController
    {
        // GET: Inventory
        public ActionResult Index()
        {
            ViewBag.Title = "Inventory";

            return View();
        }

        public ActionResult Get()
        {

            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    
                    var inventory = dbContext.Inventory
                        .Include(i => i.Strain)
                        .Include(i => i.Site)
                        .Include(i => i.InventoryQaChecks)
                        .Include(i => i.InventoryQaSamples)
                        .Where(c => !c.IsDeleted && c.AccountId == account.Id)
                        .ToList();


                    var inventoryDTO = new List<InventoryDTO>();
                    inventoryDTO.AddRange(
                        inventory.Select(i =>
                        {

                            var qaCheck = i.InventoryQaChecks.FirstOrDefault();
                            var CBD = ""; var THC = "";
                            if (qaCheck != null)
                            {
                                CBD = qaCheck.CBD;
                                THC = qaCheck.THC;
                            }
                            
                            string QAResult = "Not Implemented";
                            /*
                            if (i.InventoryQaSamples.Count > 0)
                            {
                                QAResult = i.InventoryQaSamples.Result.ToString();
                            }
                            if (!string.IsNullOrEmpty(QAResult))
                            {
                                if (QAResult.ToString() == "-1")
                                {
                                    QAResult = "Fail";
                                }
                                else if (QAResult.ToString() == "0")
                                {
                                    QAResult = "Waiting";
                                }
                                else if (QAResult.ToString() == "1")
                                {
                                    QAResult = "Pass";
                                }
                            }
                            else
                            {
                                QAResult = "-";
                            }
                            */
                            var dto = new InventoryDTO()
                            {
                                CBD = CBD,
                                ComplianceId = i.ComplianceId,
                                Description = i.ProductName,
                                Available = i.RemainingQuantity,
                                QAResult = QAResult,
                                THC = THC,
                                Type = i.Type,
                                RoomName = i.Site != null ? i.Site.Name : " - ",
                                Size = i.UsableWeight.ToString(),
                                Strain = i.Strain != null ? i.Strain.Name : " - "
                            };
                            return dto;
                        }));

                    return JsonObject(inventoryDTO);
                }
            }
        }
    }
}