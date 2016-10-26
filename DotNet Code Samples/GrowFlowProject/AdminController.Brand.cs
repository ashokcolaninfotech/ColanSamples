using GrowFlow.Api.Compliance.Service;
using GrowFlow.Model;
using GrowFlow.Model.Persistance;
using GrowFlow.Web.Attributes; 
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Http;
using GrowFlow.Model.Organization;
using GrowFlow.Web.DTO.Admin;

namespace GrowFlow.Web.WebAPI
{
    [AuthorizeUserApi]
    [Route("Brands")]
    public partial class AdminController : GrowFlowApiController
    {
        // GET: AdminControllerBrand
        [HttpGet]
        [Route("Brands")]
        public List<Brand> GetBrand(int accountId)
        {
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    var Brands = dbContext.Brands.Where(s => s.AccountId == account.Id);

                    return Brands.ToList();
                }
            }
        }

        [HttpPost]
        [Route("Brands")]
        public async Task<CreateOperationResult> CreateBrand(Brand Brand)
        {
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    try
                    {
                        var getBrand = dbContext.Brands.FirstOrDefault(s => s.AccountId == account.Id && s.Name.ToLower() == Brand.Name.ToLower());
                        if (getBrand == null)
                        {
                            Brand.AccountId = account.Id;
                            
                            dbContext.Brands.Add(Brand);

                            dbContext.SaveChanges();
                        }
                        return new CreateOperationResult()
                        {
                            Success = true,
                            Data = Brand
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
        [Route("Brands")]
        public async Task<CreateOperationResult> EditBrand(int BrandId, Brand Brand)
        {
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    Brand facility = dbContext.Set<Brand>().AsNoTracking()
                        .FirstOrDefault(s => s.AccountId == account.Id && s.Id == BrandId);

                    if (facility == null)
                    {
                        return new CreateOperationResult()
                        {
                            Success = false,
                            Exception = "Unable to edit Brand.  No facility location exists for this account."
                        };
                    }

                    try
                    {
                        // Brand.Daysinflower = .Daysinflower;

                        dbContext.Brands.Attach(Brand);

                        var entry = dbContext.Entry(Brand);
                        entry.State = EntityState.Modified;

                        dbContext.SaveChanges();

                        return new CreateOperationResult()
                        {
                            Success = true,
                            Data = Brand
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
        [Route("Brands/{id:int}/IsDeletable")]
        public DeletableDTO IsBrandDeletable(int id)
        {
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                   // bool isDeletable = service.DoesBrandContainInventory(account, BrandId);

                    return new DeletableDTO
                    {
                        IsDeletable = false,
                        Message = "Please remove all inventory from this Brand before deleting."
                    };
                }
            }
        }

        [HttpDelete]
        [Route("Brands/{id:int}")]
        public async Task<OperationResult> DeleteBrand(int id)
        {
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    try
                    {
                        var Brand = dbContext.Brands.Single(s => s.Id == id && s.AccountId == account.Id);
                        dbContext.Brands.Attach(Brand);
                        dbContext.Brands.Remove(Brand);
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