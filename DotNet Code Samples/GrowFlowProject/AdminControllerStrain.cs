using GrowFlow.Api.Compliance.Service;
using GrowFlow.Model;
using GrowFlow.Model.Persistance;
using GrowFlow.Web.Attributes;
using GrowFlow.Web.DTO.Admin;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Http;

namespace GrowFlow.Web.WebAPI
{
    [AuthorizeUserApi]
    public partial class AdminController : GrowFlowApiController
    {
        // GET: AdminControllerStrain
        [HttpGet]
        [Route("Strains")]
        public List<Strain> GetStrain(int accountId)
        {
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    var strains = dbContext.Strains.Where(s => s.AccountId == account.Id);

                    return strains.ToList();
                }
            }
        }

        [HttpPost]
        [Route("Strain")]
        public async Task<CreateOperationResult> CreateStrain(Strain strain)
        {
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    try
                    {
                        var getstrain = dbContext.Strains.FirstOrDefault(s => s.AccountId == account.Id && s.Name.ToLower() == strain.Name.ToLower());
                        if (getstrain == null)
                        {
                            dbContext.Strains.Add(strain);

                            dbContext.SaveChanges();
                        }
                        return new CreateOperationResult()
                        {
                            Success = true,
                            Data = strain
                        };
                    }
                    catch (Exception e)
                    {
                        return new CreateOperationResult()
                        {
                            Success = false,
                            Exception = e.Message
                        };
                    }
                }
            }
        }

        [HttpPut]
        [Route("Strain/{strainId:int}")]
        public async Task<CreateOperationResult> EditStrain(int strainId, Strain strain)
        {
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    Strain facility = dbContext.Set<Strain>().AsNoTracking()
                        .FirstOrDefault(s => s.AccountId == account.Id && s.Id == strainId);

                    if (facility == null)
                    {
                        return new CreateOperationResult()
                        {
                            Success = false,
                            Exception = "Unable to edit strain.  No facility location exists for this account."
                        };
                    }

                    try
                    {
                        // strain.Daysinflower = .Daysinflower;

                        dbContext.Strains.Attach(strain);

                        var entry = dbContext.Entry(strain);
                        entry.State = EntityState.Modified;

                        dbContext.SaveChanges();

                        return new CreateOperationResult()
                        {
                            Success = true,
                            Data = strain
                        };
                    }
                    catch (Exception e)
                    {
                        return new CreateOperationResult()
                        {
                            Success = false,
                            Exception = e.Message
                        };
                    }
                }
            }
        }

        [HttpGet]
        [Route("Strain/{strainId:int}/IsDeletable")]
        public DeletableDTO IsStrainDeletable(int strainId)
        {
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    bool isDeletable = service.DoesStrainContainInventory(account, strainId);
                    return new DeletableDTO
                    {
                        IsDeletable = isDeletable,
                        Message = "Please remove all inventory from this strain before deleting."
                    };
                }
            }
        }

        [HttpDelete]
        [Route("Strain/{strainId:int}")]
        public async Task<OperationResult> DeleteStrain(int strainId)
        {
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    try
                    {
                        var strain = dbContext.Strains.Single(s => s.Id == strainId && s.AccountId == account.Id);
                        dbContext.Strains.Attach(strain);
                        dbContext.Strains.Remove(strain);
                        dbContext.SaveChanges();

                        return new CreateOperationResult()
                        {
                            Success = true
                        };
                    }
                    catch (Exception e)
                    {
                        return new CreateOperationResult()
                        {
                            Success = false,
                            Exception = e.Message
                        };
                    }
                }
            }
        }
    }
}